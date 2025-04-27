class Worker:
    def __init__(self, firstname, lastname, age, type_of_deal, phone_number, email):
        self.firstname = firstname
        self.lastname = lastname
        self.age = age
        self.type_of_deal = type_of_deal
        self.phone_number = phone_number
        self.email = email
        self.work_time_preference = None
        self.max_working_hours = None
        self.tags = [] #t0 do

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


adam = Worker("adam", "kowalski", "wiek", "umowa zlecenie", 606547766, "ellele@wp.pl")
print(adam)

