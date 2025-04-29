from ortools.sat.python import cp_model

from backend.models.Constraints import Constraints

restrictions = Constraints

model = cp_model.CpModel()
