class Worker:
    def __init__(self, firstname, lastname, sex, age, type_of_deal, phone_number, email, id,max_working_hours = None):
        self.firstname = firstname
        self.lastname = lastname
        self.sex = sex
        self.age = age
        self.type_of_deal = type_of_deal
        self.phone_number = phone_number
        self.email = email
        self.work_time_preference = None
        self.max_working_hours = max_working_hours
        self.tags = [] #t0 do
        self.is_deleted = False
        self.id = id

    def __str__(self):
        tags_str = ', '.join([tag.name for tag in self.tags])
        return f"{self.firstname}|{self.lastname}|{self.age}|{self.type_of_deal}|{tags_str}|{self.get_max_working_hours()}h/tydzień"

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

    def add_tag(self, tag):
        self.tags.append(tag)


