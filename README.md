# Welcome!

This kata covers the Hidden Shift Problem, which concerns determining a hidden shift s for
boolean bent functions f and g such that g(x) = f(x + s). This is another example of a
problem that can be solved exponentially faster by a quantum algorithm than any classical
algorithms.

This Kata consists of three parts. Task 1 concerns implementing bent boolean functions for
which problem relies upon. Task 2 concerns implementing a deterministic solution to the
Hidden Shift Problem that makes O(1) oracle calls. Finally, Task 3 concerns implementing
a reduction of the Hidden Shift Problem to Simon's Algorithm and similar instances of the
Hidden Subgroup Problem. Just as in Simon's Algorithm Kata, the classical portion of the
generalized Hidden Shift Problem Algorithm is already implemented for you. However,
unlike the Simon's Algorithm Kata, we have included a Gaussian Elimination library in Q#.

#### Hidden Shift Problem
* A good place to start is [our research paper](https://en.wikipedia.org/wiki/Simon%27s_problem).
* [Lecture 6: Simon’s algorithm](https://cs.uwaterloo.ca/~watrous/CPSC519/LectureNotes/06.pdf) has a somewhat clearer description of the measurement part of the quantum circuit.
