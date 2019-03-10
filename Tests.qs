namespace HiddenShiftKata
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Testing;

    operation AlgorithmOneTest () : Unit {
        for (N in 2 .. 2 .. 4) {
            for (s in 0 .. 2^N - 1) {
                let f = InnerProductOracle(_, _);
                let g = ShiftedOracle(f, s);
                let phasef = PhaseFlipOracle(f);
                let phaseg = PhaseFlipOracle(g);
                let res = AlgorithmOne(N, phasef, phaseg);
                if (not (res == s)) {
                    Message($"{N}: {res} not equal to s = {s}");
                }
            }
        }
    }

    function InnerProductClassical (arr : Int[]) : Int {
        mutable res = 0;
        for (i in 0 .. 2 .. Length(arr) - 1) {
            if ((arr[i] == 1) && (arr[i+1] == 1)) {
                set res = res + 1;
            }
        }
        return res % 2;
    }

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

    operation InnerProductOracleTestCase (arr : Int[]) : Unit {
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

    operation InnerProductOracleTest () : Unit {
        for (N in 2 .. 2 .. 10) {
            IterateThroughCartesianPower(N, 2, InnerProductOracleTestCase);
        }
    }

    function QuadraticClassical(arr : Int[], Q : Int[][], L : Int[]) : Int {
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

    operation QuadraticOracleTestCase (arr : Int[], Q : Int[][], L : Int[]) : Unit {
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

    operation QuadraticOracleTest () : Unit {
        mutable Q = new Int[][4];
        set Q[0] = [0, 1, 1, 1];
        set Q[1] = [0, 0, 1, 1];
        set Q[2] = [0, 0, 0, 1];
        set Q[3] = [0, 0, 0, 0];
        let L = [1, 0, 0, 0];
        IterateThroughCartesianPower(Length(L), 2, QuadraticOracleTestCase(_, Q, L));
    }

}
