namespace HiddenShiftKata {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    // ...
    operation AndDualOracle (x : Qubit[], y : Qubit) : Unit {
        Controlled X(x, y);
    }

    operation ShiftedAndOracle(x : Qubit[], y : Qubit) : Unit {
        X(x[0]);
        Controlled X(x, y);
        X(x[0]);
    }

    function ConvertToPhase(oracle : ((Qubit[], Qubit) => Unit)) : ((Qubit[]) => Unit) {
        return HelpOracle(_, oracle);
    }

    operation HelpOracle (x : Qubit[], oracle : ((Qubit[], Qubit) => Unit)) : Unit {
        using (y = Qubit()) {
            X(y);
            H(y);
            oracle(x, y);
            H(y);
            X(y);
        }
    }

    operation Full(qs : Qubit[], odf : ((Qubit[], Qubit) => Unit), og : ((Qubit[], Qubit) => Unit)) : Unit {
        ApplyToEach(H, qs);
        let thing = ConvertToPhase(og);
        thing(qs);
        ApplyToEach(H, qs);
        let ding = ConvertToPhase(odf);
        ding(qs);
        ApplyToEach(H, qs);
        Message($"RESULT: {M(qs[0])} AND {M(qs[1])}");
    }
}
