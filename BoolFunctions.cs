using System.Collections.Generic;
using System.Linq;
using System;

namespace HiddenShiftKata {
    class BooleanFunction : IEnumerable<BitString> {
        public delegate bool FunctionImplementation(BitString input);

        public readonly int N;
        public int Range {
            get => 2 << (N - 1);
        }
        public int HighInputsCount {
            get {
                if (_vals == null) {
                    CharacterizeFunction();
                }
                return _vals.Count;
            }
        }
        public int LowInputsCount {
            get {
                if (_vals == null) {
                    CharacterizeFunction();
                }
                return Range - _vals.Count;
            }
        }
        public bool Bent {
            get {
                if (!_bent.HasValue) {
                    _bent = ComputeBent();
                }
                return (bool)_bent;
            }
        }
        private bool? _bent = null;
        private HashSet<BitString> _vals = null;
        private FunctionImplementation _compute = null;

        public BooleanFunction(IEnumerable<BitString> vals, int n) {
            _vals = new HashSet<BitString>(vals);
            N = n;
        }

        public BooleanFunction(HashSet<BitString> vals, int n, bool stealref=false) {
            if (stealref) { _vals = vals; }
            else { _vals = new HashSet<BitString>(vals); }
            N = n;
        }

        public BooleanFunction(FunctionImplementation implementation, int n) {
            _compute = implementation;
            N = n;
        }

        public IEnumerator<BitString> GetEnumerator() {
            return _vals.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            // call the generic version of the method
            return this.GetEnumerator();
        }

        public bool Evaluate(BitString arg) {
            if (_compute != null) {
                return _compute(arg);
            }
            return _vals.Contains(arg);
        }

        public int Walsh(BitString a) {
            Console.WriteLine("a: " + a);
            int count_equals = 0;
            for (int i = 0; i < Range; i++) {
                BitString x = BitString.GetBitString(i, N);
                Console.WriteLine("x: " + x + " f(x): " + Evaluate(x) + " a*x: " + a*x);
                if (Evaluate(x) == a * x) { count_equals += 1; }
            }
            Console.WriteLine("final count: " + count_equals + " final wv: " + (2 * count_equals - Range));
            return 2 * count_equals - Range;
        }

        private bool ComputeBent() {
            Console.WriteLine("");
            Console.WriteLine("High on:");
            foreach (var a in _vals) {
                Console.WriteLine(a);
            }
            int wv = Math.Abs(Walsh(BitString.GetBitString(0, N)));
            Console.WriteLine("WV 0: " + wv);
            for (int i = 1; i < Range; i++) {
                int temp = Math.Abs(Walsh(BitString.GetBitString(i, N)));
                Console.WriteLine("WV " + i +": " + temp);
                if (temp != wv) { return false; }
            }
            return true;
        }

        private void CharacterizeFunction() {
            HashSet<BitString> high_inputs = new HashSet<BitString>();
            for (int i = 0; i < Range; i++) {
                BitString input = BitString.GetBitString(i, N);
                if (_compute(input)) { high_inputs.Add(input); }
            }
            _vals = high_inputs;
        }

        private void GenerateDNFImplementation() {
            throw new NotImplementedException();
        }

        // the exponents' exponents have exponents
        // I don't even think there's a good way to iterate over all the positibilities
        // I'm sure there are some optimizations I missed but it 100% sucks
        // I'll be surprised if this runs for n = 4
        public static IEnumerable<BooleanFunction> GetBent(int n) {
            List<BooleanFunction> result = new List<BooleanFunction>();
            int range = 2 << (n - 1);
            bool[] selection = new bool[range];
            HashSet<BitString> positive_vals = new HashSet<BitString>();
            if (new BooleanFunction(positive_vals, n, true).Bent) {
                result.Add(new BooleanFunction(positive_vals, n));
            }
            while (true) {
                int i = 0;
                for (; i < range && selection[i]; i++) {}
                if (i == range) { break; }
                selection[i] = true;
                positive_vals.Add(BitString.GetBitString(i, n));
                for (i = i - 1; i >= 0; i--) {
                    selection[i] = false;
                    positive_vals.Remove(BitString.GetBitString(i, n));
                }
                if (new BooleanFunction(positive_vals, n, true).Bent) {
                    var temp = new BooleanFunction(positive_vals, n);
                    result.Add(temp);
                    Console.WriteLine("FOUND BENT");
                }
            }
            return result;
        }
    }

    class BitString {
        private static Dictionary<string, BitString> internment_camp = new Dictionary<string, BitString>();
        private bool[] _val;

        public bool this[int key] {
            get {
                return _val[key];
            }
        }

        public static bool operator *(BitString a, BitString b) {
            return a.DotProduct(b);
        }

        public bool[] Value {
            get {
                bool[] temp = new bool[_val.Length];
                Array.Copy(_val, temp, _val.Length);
                return temp;
            }
        }
        public int Length {
            get => _val.Length;
        }
        public readonly string Stringy;
        public static BitString GetBitString(int val, int n) {
            bool[] result = new bool[n];
            for (int i = n - 1; i >= 0; i--) {
                result[i] = val % 2 == 1;
                val /= 2;
            }
            return GetBitString(result);
        }

        public static BitString GetBitString(bool[] val) {
            BitString temp = new BitString(val);
            if (internment_camp.ContainsKey(temp.Stringy)) {
                return internment_camp[temp.Stringy];
            }
            internment_camp[temp.Stringy] = temp;
            return temp;
        }

        private BitString(bool[] val) {
            _val = new bool[val.Length];
            Array.Copy(val, _val, val.Length);
            Stringy = _ToString();
        }

        public bool DotProduct(BitString other) {
            bool product = false;
            for (int i = 0; i < Length; i++) {
                product ^= (_val[i] & other[i]);
            }
            return product;
        }

        public override string ToString() {
            return Stringy;
        }

        private string _ToString() {
            string result = "";
            foreach (bool b in _val) {
                result += b ? "1" : "0";
            }
            return String.Intern(result);
        }
    }
}