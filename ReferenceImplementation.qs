
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

    // Implement the inner product oracle, which is the most basic kind
    // of bent function.
    // The dual of the inner product function is itself.
    operation InnerProductOracle(x : Qubit[], target : Qubit) : Unit {
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
    operation QuadraticOracle(x : Qubit[], target : Qubit, Q : Int[][], L : Int[]) : Unit {
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

    // Given an integer s, prepare the given qubit register with the integer in little endian order.
    operation PrepareQubitFromInt(qs : Qubit[], s : Int) : Unit {
        body (...) {
            let N = Length(qs);
            for (i in 0 .. N - 1)  {
                if (((s >>> i) % 2) == 1) {
                    X(qs[i]);
                }
            }
        }
        controlled adjoint auto;
        controlled auto;
        adjoint auto;
    }

    operation ShiftedOracleHelper(f : ((Qubit[], Qubit) => Unit : Controlled), s : Int, x : Qubit[], target : Qubit) : Unit {
        body (...) {
            let N = Length(x);
            using (qs = Qubit[N]) {
                PrepareQubitFromInt(qs, s);
                for (i in 0 .. N - 1) {
                    CNOT(x[i], qs[i]);
                }
                f(qs, target);
                for (i in 0 .. N - 1) {
                    CNOT(x[i], qs[i]);
                }
                Adjoint PrepareQubitFromInt(qs, s);
            }
        }
        controlled auto;
    }

    // Returns the shifted oracle g for a marking oracle f such that g(x) = f(x + s).
    function ShiftedOracle(f : ((Qubit[], Qubit) => Unit : Controlled), s : Int) : ((Qubit[], Qubit) => Unit : Controlled) {
        return ShiftedOracleHelper(f, s, _, _);
    }

    operation PhaseFlipOracleHelper(f : ((Qubit[], Qubit) => Unit : Controlled), x : Qubit[]) : Unit {
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
        controlled auto;
    }

    // Returns the phase flip oracle corresponding to the marking oracle f.
    function PhaseFlipOracle(f : ((Qubit[], Qubit) => Unit : Controlled)) : ((Qubit[]) => Unit : Controlled) {
        return PhaseFlipOracleHelper(f, _);
    }

    //--------------------------------------------------------------------
    // Determines the hidden shift s from the oracle for g(x) and the daul of f(x).
    operation AlgorithmOne(N : Int, oracledualf : ((Qubit[]) => Unit), oracleg : ((Qubit[]) => Unit)) : Int {
        mutable res = 0;
        using (qs = Qubit[N]) {
            ApplyToEach(H, qs);
            oracleg(qs);
            ApplyToEach(H, qs);
            oracledualf(qs);
            ApplyToEach(H, qs);
            set res = MeasureInteger(LittleEndian(qs));
            ResetAll(qs);
        }
        return res;
    }
}
