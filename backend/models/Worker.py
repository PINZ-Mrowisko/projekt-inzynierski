class Worker:
    def __init__(self, firstname, lastname, age, type_of_deal, phone_number, email, max_working_hours = None):
        self.firstname = firstname
        self.lastname = lastname
        self.age = age
        self.type_of_deal = type_of_deal
        self.phone_number = phone_number
        self.email = email
        self.work_time_preference = None
        self.max_working_hours = max_working_hours
        self.tags = [] #t0 do
        self.is_deleted = False

    def get_type_of_deal(self):
        return self.type_of_deal

    def get_max_working_hours(self):
        deal = self.get_type_of_deal()

        if deal == "umowa zlecenie":
            return self.max_working_hours
        elif deal == "umowa o prace":
            return 40
        else:
            return 20 #pół etatu

    def delete_worker(self):
        self.is_deleted = True

    def __str__(self):
        return f"{self.firstname}|{self.lastname}|{self.age}|{self.type_of_deal}|{self.get_max_working_hours()}h/tydzień"

