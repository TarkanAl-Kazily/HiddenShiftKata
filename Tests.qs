namespace HiddenShiftKata
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    operation AlgorithmOneTest () : Unit {
        for (N in 2 .. 2 .. 2) {
            for (s in 0 .. 2^N - 1) {
                let f = InnerProductOracle(_, _);
                let g = ShiftedOracle(f, s);
                let phasef = PhaseFlipOracle(f);
                let phaseg = PhaseFlipOracle(g);
                let res = AlgorithmOne(N, phasef, phaseg);
                if (not (res == s)) {
                    Message($"{res} not equal to s = {s}");
                }
            }
        }
    }

}
