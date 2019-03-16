namespace HiddenShiftKata
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////

    // "HiddenShiftKata" quantum kata is a series of exercises designed to
    // guide you in implementing algorithms to solve the Hidden Shift Problem
    // It covers the following topics:
    //  - bent boolean oracles,
    //  - a correlation based solution to the Hidden Shift Problem,
    //  - a Hidden Subgroup based solution to the Hidden Shift Problem.

    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.

    // None of the tasks require measurement.

    //////////////////////////////////////////////////////////////////
    // Part I. Bent Boolean Oracles
    //////////////////////////////////////////////////////////////////

    // Task 1.1: Inner Product Oracle f(x) = \sum x_{i} x_{i+1}
    // The binary inner product is the most natural kind of bent function,
    // and has the property where the dual of the inner product oracle is
    // itself.
    // Inputs:
    //      1) N qubits in arbitrary state |x> (input register) (N is even)
    //      2) a qubit in arbitrary state |target> (output qubit)
    // Goal: transform state |x, target> into state |x, target + f(x)> (+ is addition modulo 2).
    operation InnerProductOracle(x : Qubit[], target : Qubit) : Unit {
        body (...) {
            // ...
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    // Task 1.2: Quadratic Boolean Oracle f(x) = x Q x^T + L x^T
    // Quadratic boolean functions are bent when the symplectic B = Q + Q^T
    // has full rank. The dual of a quadratic bent function will then be
    // a quadratic bent function.
    // Inputs:
    //      1) N qubits in arbitrary state |x> (input register) (N is even)
    //      2) a qubit in arbitrary state |target> (output qubit)
    //      3) an upper triangular N by N matrix Q with 0s along the diagonal
    //      4) an N length vector L
    // Goal: transform state |x, target> into state |x, target + f(x)> (+ is addition modulo 2).
    operation QuadraticOracle(x : Qubit[], target : Qubit, Q : Int[][], L : Int[]) : Unit {
        body (...) {
            // ...
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    // Task 1.3: Phase Flip Oracles
    // Given a marking oracle f that takes |x>|y> to |x>|y + f(x)>,
    // return a phase flip oracle that takes |x> to (-1)^
    // Inputs:
    //      1) a marking oracle f
    // Goal: return an oracle that transforms state |x> into state (-1)^f(x) |x>
    function PhaseFlipOracle(f : ((Qubit[], Qubit) => Unit : Controlled)) : ((Qubit[]) => Unit : Controlled) {
        // ...
        // This task returns the identity gate so that it compiles. You'll likely
        // need to return your own operation in order to get this to work.
        return ApplyToEachCA(I, (_));
    }

    //////////////////////////////////////////////////////////////////
    // Part II. Correlation Based Solution to the Hidden Shift Problem
    //////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////
    // Part III. Hidden Subgroup Based Solution to the Hidden Shift Problem
    //////////////////////////////////////////////////////////////////
}
