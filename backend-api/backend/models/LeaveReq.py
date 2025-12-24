class LeaveReq:
    def __init__(self, id, employee_id, start_date, end_date, status):
        self.id = id
        self.employee_id = employee_id
        self.start_date = start_date
        self.end_date = end_date
        self.status = status

    def convert_to_dict(self):
        return {
            "leave_id": self.id,
            "employee_id": self.employee_id,
            "start_date": self.start_date,
            "end_date": self.end_date,
            "status": self.status,
        }