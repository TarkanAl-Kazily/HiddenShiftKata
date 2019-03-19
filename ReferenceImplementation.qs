//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// The tasks themselves can be found in Tasks.qs file.
// We recommend that you try to solve the tasks yourself first,
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace HiddenShiftKata
{

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Diagnostics;

    //--------------------------------------------------------------------

    // Implement the inner product oracle, which is the most basic kind
    // of bent function.
    // The dual of the inner product function is itself.
    operation InnerProductOracle_Reference(x : Qubit[], target : Qubit) : Unit {
        body (...) {
            let N = Length(x);
            AssertBoolEqual(((N % 2) == 0) && (N > 0), true, "The number of input qubits must be even and positive");
            for (i in 0 .. 2 .. N-1) {
                CCNOT(x[i], x[i+1], target);
            }
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    // Implement a quadratic boolean function oracle.
    // Q is an upper triangular matrix of 0's and 1's with 0's along the diagonal.
    // L is a row vector of 0's and 1's
    operation QuadraticOracle_Reference(x : Qubit[], target : Qubit, Q : Int[][], L : Int[]) : Unit {
        body (...) {
            let N = Length(x);
            AssertIntEqual(N, Length(L), "The length of x and L must be equal");
            AssertIntEqual(N, Length(Q), "The length of x and Q must be equal");
            AssertIntEqual(Length(Q), Length(Q[0]), "Q must be a square matrix");
            for (j in 0 .. N-1) {
                if (L[j] == 1) {
                    CNOT(x[j], target);
                }
                for (i in 0 .. j - 1) {
                    if (Q[i][j] == 1) {
                        CCNOT(x[i], x[j], target);
                    }
                }
            }
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    //--------------------------------------------------------------------

    operation ShiftedOracle_Helper_Reference(f : ((Qubit[], Qubit) => Unit : Adjoint, Controlled), s : Int[], x : Qubit[], target : Qubit) : Unit {
        body (...) {
            let N = Length(x);
            using (qs = Qubit[N]) {
                for (i in 0 .. N-1) {
                    if (s[i] == 1) {
                        X(qs[i]);
                    }
                }
                for (i in 0 .. N - 1) {
                    CNOT(x[i], qs[i]);
                }
                f(qs, target);
                for (i in 0 .. N - 1) {
                    CNOT(x[i], qs[i]);
                }
                for (i in 0 .. N-1) {
                    if (s[i] == 1) {
                        X(qs[i]);
                    }
                }
            }
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    // Returns the shifted oracle g for a marking oracle f such that g(x) = f(x + s).
    function ShiftedOracle_Reference(f : ((Qubit[], Qubit) => Unit : Adjoint, Controlled), s : Int[]) : ((Qubit[], Qubit) => Unit : Adjoint, Controlled) {
        return ShiftedOracle_Helper_Reference(f, s, _, _);
    }

    operation PhaseFlipOracle_Helper_Reference(f : ((Qubit[], Qubit) => Unit : Adjoint, Controlled), x : Qubit[]) : Unit {
        body (...) {
            let N = Length(x);
            using (b = Qubit()) {
                X(b);
                H(b);
                f(x, b);
                H(b);
                X(b);
            }
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    // Returns the phase flip oracle corresponding to the marking oracle f.
    function PhaseFlipOracle_Reference(f : ((Qubit[], Qubit) => Unit : Adjoint, Controlled)) : ((Qubit[]) => Unit : Adjoint, Controlled) {
        return PhaseFlipOracle_Helper_Reference(f, _);
    }

    //--------------------------------------------------------------------

    operation WalshHadamard_Reference (x : Qubit[]) : Unit {
        body (...) {
            ApplyToEachA(H, x);
        }
        adjoint auto;
    }

    // Determines the hidden shift s from the oracle for g(x) and the daul of f(x).
    operation DeterministicHiddenShiftSolution_Reference (N : Int, Ug : ((Qubit[]) => Unit), Ufd : ((Qubit[]) => Unit)) : Int[] {
        mutable res = new Int[N];
        using (qs = Qubit[N]) {
            ApplyToEach(H, qs);
            Ug(qs);
            WalshHadamard_Reference(qs);
            Ufd(qs);
            WalshHadamard_Reference(qs);
            for (i in 0 .. N-1) {
                set res[i] = M(qs[i]) == One ? 1 | 0;
            }
            ResetAll(qs);
        }
        return res;
    }

    //--------------------------------------------------------------------

    operation HidingFunctionOracle_Helper_Reference (f : ((Qubit[]) => Unit : Adjoint, Controlled), g : ((Qubit[]) => Unit : Adjoint, Controlled),
                                                     b : Qubit, x : Qubit[], target : Qubit[]) : Unit {
        body (...) {
            ApplyToEachCA(H, target);
            for (i in 0 .. Length(x) - 1) {
                CNOT(x[i], target[i]);
            }

            Controlled g([b], (target));
            X(b);
            Controlled f([b], (target));
            X(b);

            for (i in 0 .. Length(x) - 1) {
                CNOT(x[i], target[i]);
            }
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    function HidingFunctionOracle_Reference (f : ((Qubit[]) => Unit : Adjoint, Controlled), g : ((Qubit[]) => Unit : Adjoint, Controlled)) :
            ((Qubit, Qubit[], Qubit[]) => Unit : Adjoint, Controlled) {
        return HidingFunctionOracle_Helper_Reference(f, g, _, _, _);
    }

	operation IterativeHiddenShiftSolution_Reference(n: Int, oraclef : ((Qubit[]) => Unit : Controlled), oracleg : ((Qubit[]) => Unit : Controlled)) : Int[] {
        using ((cosetReg, targetReg) = (Qubit[n+1], Qubit[n])) {

        }
        return [42];
	}
}
