## This package is still WIP

## `package:uimatrix`

A vector math library (like `package:vector_math`) optimized for 2D use-cases.
3D is supported to, but there's no current goal to beat `package:vector_math` at
general 3D operations, merely to be on par. 2D use-cases should be many times
faster though.

## Design

This package makes the following hypotheses about vector math usage in typical
2D apps, such as the Flutter framework and engine, and apps using them:

* Identity and 2D translations are the most common kinds of matrices used.
  Therefore the object representation is optimized for these kinds of
  matrices.
* Precision higher than float32 is overkill for the 2D UI use-case.

With these assumptions, the package makes the following design choices to
maximize performance:

* The matrix class is monomorphic for fastest method/field access.
* The matrix class is deeply immutable and const.
* Zero and identity matrices are canonicalized: there's exactly one constant
  instance for each. This makes checking for identity trivial.
* Matrix initialization lowers to the most specific matrix kind. If a 4x4
  matrix is actually an identity matrix, the constructor will return the
  identity constant.
* Specialized algorithms based on matrix kind.
* Input types are always the most concrete numeric types (doubles, typed
  list), unlike `package:vector_math` that takes varargs and dynamic types
  and performs runtime pattern matching on arguments.
* Minimize boxing: a 2D translation (including identity) only needs x and y
  values. No need for extra arrays.
