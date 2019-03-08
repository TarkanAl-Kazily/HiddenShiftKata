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

}
