namespace HiddenShiftKata
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    operation tTest () : Unit {
        using (qs = Qubit[2]) {
            Full(qs, AndDualOracle, ShiftedAndOracle);
            X(qs[0]);
        }
    }
}
