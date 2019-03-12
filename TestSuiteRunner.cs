using Microsoft.Quantum.Simulation.XUnit;
using Microsoft.Quantum.Simulation.Simulators;
using Xunit.Abstractions;
using System.Diagnostics;

namespace HiddenShiftKata
{
    public class TestSuiteRunner
    {
        private readonly ITestOutputHelper output;

        public TestSuiteRunner(ITestOutputHelper output)
        {
            this.output = output;
        }

        /// <summary>
        /// This driver will run all Q# tests (operations named "...Test") 
        /// that belong to namespace HiddenShiftKata.
        ///
        /// To execute your tests, just type "dotnet test" from the command line.
        /// </summary>
        [OperationDriver(TestNamespace = "HiddenShiftKata")]
        public void TestTarget(TestOperation op)
        {
            var hi = BooleanFunction.GetBent(4);
            System.Console.WriteLine("Count: " + ((System.Collections.Generic.List<BooleanFunction>)hi).Count);
            foreach (var a in hi) {
                System.Console.WriteLine("function:");
                foreach (var b in a) {
                    System.Console.WriteLine(b);
                }
                System.Console.WriteLine();
            }
            using (var sim = new QuantumSimulator())
            {
                // OnLog defines action(s) performed when Q# test calls function Message
                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };
                op.TestOperationRunner(sim);
            }
        }
    }
}
