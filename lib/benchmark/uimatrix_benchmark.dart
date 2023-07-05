import 'dart:math' as math;
import 'package:uimatrix/uimatrix.dart';
import 'package:vector_math/vector_math_64.dart';
import 'harness.dart';

const int N = 10000;

Future<void> main() async {
  benchmarkHarness = BenchmarkHarness(printer: TsvResultsPrinter());

  group('Harness overhead', () {
    benchmark('Empty benchmark', () {
      return null;
    }, postCompute: (Object? result) {});

    benchmark('Iteration', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        total += i;
      }
      return total;
    });
  });

  group('Instantiation', () {
    benchmark('Identity (Matrix4)', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        total += Matrix4.identity().storage[0];
      }
      return total;
    });

    benchmark('Identity (UiMatrix)', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        total += UiMatrix.identity.scaleX;
      }
      return total;
    });

    benchmark('2D translation (Matrix4)', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        total += Matrix4.translationValues(0.4, 3.45, 0).storage[0];
      }
      return total;
    });

    benchmark('2D translation (UiMatrix)', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        total += UiMatrix.translation2d(dx: 0.4, dy: 3.45).scaleX;
      }
      return total;
    });

    benchmark('Simple 2D (Matrix4)', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        total += (Matrix4.identity()
          ..translate(0.4, 3.45)
          ..scale(1.2, 2.3)).storage[0];
      }
      return total;
    });

    benchmark('Simple 2D (UiMatrix)', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        total += UiMatrix.simple2d(scaleX: 1.2, scaleY: 2.3, dx: 0.4, dy: 3.45).scaleX;
      }
      return total;
    });

    benchmark('Complex (Matrix4)', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        total += (Matrix4.identity()
          ..rotateZ(0.1)
          ..translate(0.4, 3.45)).storage[0];
      }
      return total;
    });

    benchmark('Complex (UiMatrix)', () {
      double total = 0;
      for (int i = 0; i < N; i++) {
        final cosAngle = math.cos(0.1);
        final sinAngle = math.sin(0.1);
        total += UiMatrix.transform2d(
          scaleX: cosAngle,
          scaleY: cosAngle,
          k1: -sinAngle,
          k2: sinAngle,
          dx: 0.4,
          dy: 3.45,
        ).scaleX;
      }
      return total;
    });
  });

  group('Multiplication', () {
    late UiMatrix a;
    late UiMatrix b;
    late Matrix4 a4;
    late Matrix4 b4;

    benchmark(
      'Identity x Identity (Matrix4)',
      setup: () {
        a4 = Matrix4.identity();
        b4 = Matrix4.identity();
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a4 * b4 as Matrix4).storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Identity x Identity (UiMatrix)',
      setup: () {
        a = UiMatrix.identity;
        b = UiMatrix.identity;
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a * b).scaleX;
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D x Identity (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..translate(0.4, 3.45)
          ..scale(1.2, 2.3);
        b4 = Matrix4.identity();
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a4 * b4 as Matrix4).storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D x Identity (UiMatrix)',
      setup: () {
        a = UiMatrix.simple2d(scaleX: 1.2, scaleY: 2.3, dx: 0.4, dy: 3.45);
        b = UiMatrix.identity;
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a * b).scaleX;
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D x Simple 2D (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..translate(0.4, 3.45)
          ..scale(1.2, 2.3);
        b4 = Matrix4.identity()
          ..translate(0.5, 3.46)
          ..scale(1.7, 2.8);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a4 * b4 as Matrix4).storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D x Simple 2D (UiMatrix)',
      setup: () {
        a = UiMatrix.simple2d(scaleX: 1.2, scaleY: 2.3, dx: 0.4, dy: 3.45);
        b = UiMatrix.simple2d(scaleX: 1.3, scaleY: 2.4, dx: 0.5, dy: 3.46);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a * b).scaleX;
        }
        return total;
      },
    );

    benchmark(
      'Complex x Complex (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..rotateZ(0.1)
          ..translate(0.4, 3.45);
        b4 = Matrix4.identity()
          ..rotateZ(0.2)
          ..translate(0.3, 3.44);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a4 * b4 as Matrix4).storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Complex x Complex (UiMatrix)',
      setup: () {
        a = UiMatrix.transform2d(
          scaleX: math.cos(0.1),
          scaleY: math.cos(0.1),
          k1: -math.sin(0.1),
          k2: math.sin(0.1),
          dx: 0.4,
          dy: 3.45,
        );
        b = UiMatrix.transform2d(
          scaleX: math.cos(0.2),
          scaleY: math.cos(0.2),
          k1: -math.sin(0.2),
          k2: math.sin(0.2),
          dx: 0.4,
          dy: 3.45,
        );
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a * b).scaleX;
        }
        return total;
      },
    );
  });

  group('Addition', () {
    late UiMatrix a;
    late UiMatrix b;
    late Matrix4 a4;
    late Matrix4 b4;

    benchmark(
      'Identity + Identity (Matrix4)',
      setup: () {
        a4 = Matrix4.identity();
        b4 = Matrix4.identity();
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a4 + b4).storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Identity + Identity (UiMatrix)',
      setup: () {
        a = UiMatrix.identity;
        b = UiMatrix.identity;
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a + b).scaleX;
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D + Identity (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..translate(0.4, 3.45)
          ..scale(1.2, 2.3);
        b4 = Matrix4.identity();
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a4 + b4).storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D + Identity (UiMatrix)',
      setup: () {
        a = UiMatrix.simple2d(scaleX: 1.2, scaleY: 2.3, dx: 0.4, dy: 3.45);
        b = UiMatrix.identity;
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a + b).scaleX;
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D + Simple 2D (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..translate(0.4, 3.45)
          ..scale(1.2, 2.3);
        b4 = Matrix4.identity()
          ..translate(0.5, 3.46)
          ..scale(1.7, 2.8);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a4 + b4).storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D + Simple 2D (UiMatrix)',
      setup: () {
        a = UiMatrix.simple2d(scaleX: 1.2, scaleY: 2.3, dx: 0.4, dy: 3.45);
        b = UiMatrix.simple2d(scaleX: 1.3, scaleY: 2.4, dx: 0.5, dy: 3.46);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a + b).scaleX;
        }
        return total;
      },
    );

    benchmark(
      'Complex + Complex (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..rotateZ(0.1)
          ..translate(0.4, 3.45);
        b4 = Matrix4.identity()
          ..rotateZ(0.2)
          ..translate(0.3, 3.44);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a4 + b4).storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Complex + Complex (UiMatrix)',
      setup: () {
        a = UiMatrix.transform2d(
          scaleX: math.cos(0.1),
          scaleY: math.cos(0.1),
          k1: -math.sin(0.1),
          k2: math.sin(0.1),
          dx: 0.4,
          dy: 3.45,
        );
        b = UiMatrix.transform2d(
          scaleX: math.cos(0.2),
          scaleY: math.cos(0.2),
          k1: -math.sin(0.2),
          k2: math.sin(0.2),
          dx: 0.4,
          dy: 3.45,
        );
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += (a + b).scaleX;
        }
        return total;
      },
    );
  });

  group('Inversion', () {
    late UiMatrix a;
    late Matrix4 a4;

    benchmark(
      'Identity (Matrix4)',
      setup: () {
        a4 = Matrix4.identity();
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          final Matrix4 m = Matrix4.zero()..copyInverse(a4);
          total += m.storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Identity (UiMatrix)',
      setup: () {
        a = UiMatrix.identity;
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a.invert()!.scaleX;
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..translate(0.4, 3.45)
          ..scale(1.2, 2.3);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          final Matrix4 m = Matrix4.zero()..copyInverse(a4);
          total += m.storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D (UiMatrix)',
      setup: () {
        a = UiMatrix.simple2d(scaleX: 1.2, scaleY: 2.3, dx: 0.4, dy: 3.45);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a.invert()!.scaleX;
        }
        return total;
      },
    );

    benchmark(
      'Complex (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..rotateZ(0.1)
          ..translate(0.4, 3.45);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          final Matrix4 m = Matrix4.zero()..copyInverse(a4);
          total += m.storage[0];
        }
        return total;
      },
    );

    benchmark(
      'Complex (UiMatrix)',
      setup: () {
        a = UiMatrix.transform2d(
          scaleX: math.cos(0.1),
          scaleY: math.cos(0.1),
          k1: -math.sin(0.1),
          k2: math.sin(0.1),
          dx: 0.4,
          dy: 3.45,
        );
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a.invert()!.scaleX;
        }
        return total;
      },
    );
  });

  group('Determinant', () {
    late UiMatrix a;
    late Matrix4 a4;

    benchmark(
      'Identity (Matrix4)',
      setup: () {
        a4 = Matrix4.identity();
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a4.determinant();
        }
        return total;
      },
    );

    benchmark(
      'Identity (UiMatrix)',
      setup: () {
        a = UiMatrix.identity;
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a.determinant();
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..translate(0.4, 3.45)
          ..scale(1.2, 2.3);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a4.determinant();
        }
        return total;
      },
    );

    benchmark(
      'Simple 2D (UiMatrix)',
      setup: () {
        a = UiMatrix.simple2d(scaleX: 1.2, scaleY: 2.3, dx: 0.4, dy: 3.45);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a.determinant();
        }
        return total;
      },
    );

    benchmark(
      'Complex (Matrix4)',
      setup: () {
        a4 = Matrix4.identity()
          ..rotateZ(0.1)
          ..translate(0.4, 3.45);
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a4.determinant();
        }
        return total;
      },
    );

    benchmark(
      'Complex (UiMatrix)',
      setup: () {
        a = UiMatrix.transform2d(
          scaleX: math.cos(0.1),
          scaleY: math.cos(0.1),
          k1: -math.sin(0.1),
          k2: math.sin(0.1),
          dx: 0.4,
          dy: 3.45,
        );
      },
      () {
        double total = 0;
        for (int i = 0; i < N; i++) {
          total += a.determinant();
        }
        return total;
      },
    );
  });

  await benchmarkHarness.run();
}
