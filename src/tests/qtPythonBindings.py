"""Headless smoke tests for the generated PyQt5 editor binding."""

import argparse
import os
from pathlib import Path
import sys
import unittest

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

parser = argparse.ArgumentParser()
parser.add_argument("--module-dir", required=True, type=Path)
options, unittest_args = parser.parse_known_args()
sys.path.insert(0, str(options.module_dir.resolve()))

# Import Qt first so its wheel configures platform-plugin and DLL discovery.
from PyQt5 import QtWidgets, sip
import expreditor2


class QtPythonBindings(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.application = QtWidgets.QApplication.instance() or QtWidgets.QApplication([])

    def test_expression_and_signal(self):
        parent = QtWidgets.QWidget()
        controls = expreditor2.ExprControlCollection(parent)
        editor = expreditor2.ExprEditor(parent, controls)
        expression = "# café — 🌱\n$length = 0.5; #0,1\n$length"
        editor.setExpr(expression)
        self.assertEqual(editor.getExpr(), expression)
        calls = []
        editor.apply.connect(lambda: calls.append(True))
        editor.apply.emit()
        self.assertEqual(calls, [True])
        with self.assertRaises(TypeError):
            editor.setExpr(123)
        with self.assertRaises(UnicodeEncodeError):
            editor.setExpr("\ud800")
        sip.delete(parent)

    def test_dialog_and_curve_constructors(self):
        dialog = expreditor2.ExprDialog()
        expression = "$length = 0.5; #0,1\n$length"
        dialog.setExpressionString(expression)
        self.assertEqual(dialog.getExpressionString(), expression)
        curve = expreditor2.ExprCurve(dialog, "Position", "Value", "Interpolation", False)
        color_curve = expreditor2.ExprColorCurve(dialog, "Position", "Color", "Interpolation", False)
        self.assertIsInstance(curve, QtWidgets.QWidget)
        self.assertIsInstance(color_curve, QtWidgets.QWidget)
        sip.delete(dialog)


if __name__ == "__main__":
    unittest.main(argv=[sys.argv[0]] + unittest_args)
