﻿namespace HiddenShiftKata
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Testing;

    // ------------------------------------------------------
    operation PrepareQubitRegister (qs : Qubit[], arr : Int[]) : Unit {
        body (...) {
            let N = Length(qs);
            for (i in 0 .. N - 1) {
                if (arr[i] == 1) {
                    X(qs[i]);
                }
            }
        }
        adjoint auto;
    }
    
    operation ApplyOracleA (qs : Qubit[], oracle : ((Qubit[], Qubit) => Unit : Adjoint)) : Unit {
        
        body (...) {
            let N = Length(qs);
            oracle(qs[0 .. N - 2], qs[N - 1]);
        }
        
        adjoint invert;
    }
    
    
    operation ApplyOracleWithOutputArrA (qs : Qubit[], oracle : ((Qubit[], Qubit[]) => Unit : Adjoint), outputSize : Int) : Unit {
        
        body (...) {
            let N = Length(qs);
            oracle(qs[0 .. (N - 1) - outputSize], qs[N - outputSize .. N - 1]);
        }
        
        adjoint invert;
    }
    
    
    operation AssertTwoOraclesAreEqual (
        nQubits : Range, 
        oracle1 : ((Qubit[], Qubit) => Unit : Adjoint), 
        oracle2 : ((Qubit[], Qubit) => Unit : Adjoint)) : Unit {
        let sol = ApplyOracleA(_, oracle1);
        let refSol = ApplyOracleA(_, oracle2);
        
        for (i in nQubits) {
            AssertOperationsEqualReferenced(sol, refSol, i + 1);
        }
    }
    

    //--------------------------------------------------------------------

    function InnerProductClassical (arr : Int[]) : Int {
        mutable res = 0;
        for (i in 0 .. 2 .. Length(arr) - 1) {
            if ((arr[i] == 1) && (arr[i+1] == 1)) {
                set res = res + 1;
            }
        }
        return res % 2;
    }

    operation InnerProductOracle_TestCase (arr : Int[]) : Unit {
        let expected = InnerProductClassical(arr);
        let N = Length(arr);
        using ((qs, target) = (Qubit[N], Qubit())) {
            PrepareQubitRegister(qs, arr);
            InnerProductOracle(qs, target);
            if (expected == 1) {
                X(target);
            }
            Adjoint PrepareQubitRegister(qs, arr);
            AssertAllZero(qs);
            AssertAllZero([target]);
        }
    }

    operation InnerProductOracle_Test () : Unit {
        for (N in 2 .. 2 .. 10) {
            IterateThroughCartesianPower(N, 2, InnerProductOracle_TestCase);
        }
    }

    //--------------------------------------------------------------------

    function QuadraticClassical (arr : Int[], Q : Int[][], L : Int[]) : Int {
        let N = Length(arr);
        mutable res = 0;
        for (j in 0 .. N - 1) {
            set res = res + L[j]*arr[j];
            for (i in 0 .. j - 1) {
                set res = res + Q[i][j] * arr[i] * arr[j];
            }
            set res = res % 2;
        }
        return res;
    }

    operation QuadraticOracle_TestCase (arr : Int[], Q : Int[][], L : Int[]) : Unit {
        let expected = QuadraticClassical(arr, Q, L);
        let N = Length(arr);
        using ((qs, target) = (Qubit[N], Qubit())) {
            PrepareQubitRegister(qs, arr);
            QuadraticOracle(qs, target, Q, L);
            if (expected == 1) {
                X(target);
            }
            Adjoint PrepareQubitRegister(qs, arr);
            AssertAllZero(qs);
            AssertAllZero([target]);
        }
    }

    operation QuadraticOracle_Test () : Unit {
        mutable Q = new Int[][4];
        set Q[0] = [0, 1, 1, 1];
        set Q[1] = [0, 0, 1, 1];
        set Q[2] = [0, 0, 0, 1];
        set Q[3] = [0, 0, 0, 0];
        let L = [1, 0, 0, 0];
        IterateThroughCartesianPower(Length(L), 2, QuadraticOracle_TestCase(_, Q, L));
    }

    //--------------------------------------------------------------------

    operation ShiftedOracle_TestCase (s : Int[]) : Unit {
        let f = InnerProductOracle_Reference(_, _);
        let fshifted = ShiftedOracle(f, s);
        let expected = ShiftedOracle_Reference(f, s);
        AssertTwoOraclesAreEqual(Length(s) .. Length(s), fshifted, expected);
    }

    operation ShiftedOracle_Test () : Unit {
        for (N in 2 .. 2 .. 6) {
            IterateThroughCartesianPower(N, 2, ShiftedOracle_TestCase);
        }
    }

    //--------------------------------------------------------------------

    operation PhaseFlipOracle_Test () : Unit {
        let f = InnerProductOracle_Reference(_, _);
        let fphased = PhaseFlipOracle(f);
        let expected = PhaseFlipOracle_Reference(f);
        for (N in 2 .. 2 .. 6) {
            AssertOperationsEqualReferenced(fphased, expected, N);
        }
    }

    //--------------------------------------------------------------------

    operation WalshHadamard_Test () : Unit {
        for (N in 1 .. 6) {
            AssertOperationsEqualReferenced(WalshHadamard, WalshHadamard_Reference, N);
        }
    }

    operation DeterministicHiddenShiftSolution_TestCase (s : Int[]) : Unit {
        let N = Length(s);
        let f = InnerProductOracle_Reference(_, _);
        let g = ShiftedOracle_Reference(f, s);
        let phasef = PhaseFlipOracle_Reference(f);
        let phaseg = PhaseFlipOracle_Reference(g);
        let res = DeterministicHiddenShiftSolution(N, phaseg, phasef);
        for (j in 0 .. N-1) {
            if (not (res[j] == s[j])) {
                fail $"Got {res}. Expected {s}";
            }
        }
    }

    operation DeterministicHiddenShiftSolution_Test () : Unit {
        for (N in 2 .. 2 .. 4) {
            IterateThroughCartesianPower(N, 2, DeterministicHiddenShiftSolution_TestCase);
        }
    }

    //--------------------------------------------------------------------

    operation HidingFunctionOracle_Test () : Unit {
        using (b = Qubit()) {
            // The choices of f and g are arbitrary for testing purposes.
            let s = [0, 1, 0, 0];
            let f = InnerProductOracle_Reference(_, _);
            let g = ShiftedOracle_Reference(f, s);
            let h = HidingFunctionOracle_Reference(PhaseFlipOracle_Reference(f), PhaseFlipOracle_Reference(g));
            let nqubits = Length(s);

            //AssertTwoOraclesAreEqual(nqubits .. nqubits, f, h(b, _, _));
            X(b);
            //AssertTwoOraclesAreEqual(nqubits .. nqubits, g, h(b, _, _));
            X(b);
        }
    }

    operation HiddenShiftIteration_TestCase (s : Int[]) : Unit {
        let N = Length(s);
        let f = InnerProductOracle_Reference(_, _);
        let g = ShiftedOracle_Reference(f, s);
        let phasef = PhaseFlipOracle_Reference(f);
        let phaseg = PhaseFlipOracle_Reference(g);

        mutable res = new Int[N];
        let num_iterations = 4;
        mutable iterations = num_iterations;
		repeat {
            set res = HiddenShiftIteration(N, phasef, phaseg);
            set iterations = iterations - 1;
		} until ((iterations == 0) || (QuickRank([res]) == 1))
		fixup {}
        if (QuickRank([res]) == 0) {
            fail $"HiddenShiftIteration did not produce a non-zero result in {num_iterations} iterations";
        }
        mutable sum = res[0];
        for (i in 1 .. N) {
            set sum = sum + s[i - 1] * res[i];
        }
        if (not (sum % 2 == 0)) {
            fail $"{res} is not orthogonal to (1, {s})";
        }
    }

	operation GeneralizedHiddenShift(n: Int, oraclef : ((Qubit[]) => Unit : Adjoint, Controlled), oracleg : ((Qubit[]) => Unit : Adjoint, Controlled)) : Int[] {
		mutable results = new Int[][n+1];
        for (i in 0 .. Length(results) - 1) {
            set results[i] = new Int[n+1];
        }
		repeat {
			let newResult = HiddenShiftIteration(n, oraclef, oracleg);

			let currentRank = RankMod2(results);
			set results[currentRank] = newResult;
		} until (Length(KernelMod2(results)) == 1)
		fixup {}

		return (KernelMod2(results))[0];
	}

    operation GeneralizedHiddenShift_TestCase (s : Int[]) : Unit {
        let f = InnerProductOracle_Reference(_, _);
        let g = ShiftedOracle_Reference(f, s);
        let phasef = PhaseFlipOracle_Reference(f);
        let phaseg = PhaseFlipOracle_Reference(g);

        let res = (GeneralizedHiddenShift(Length(s), phasef, phaseg))[1 .. Length(s)];
        for (i in 0 .. Length(s) - 1) {
            if (not (s[i] == res[i])) {
                fail $"Got {res}. Expected {s}";
            }
        }
    }

    operation HiddenShiftIteration_Test () : Unit {
        for (N in 2 .. 2 .. 4) {
            IterateThroughCartesianPower(N, 2, HiddenShiftIteration_TestCase);
        }
        for (N in 2 .. 2 .. 4) {
            IterateThroughCartesianPower(N, 2, GeneralizedHiddenShift_TestCase);
        }
    }

}
