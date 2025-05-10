from ortools.sat.python import cp_model

from backend.models.Constraints import Constraints
from backend.models.Tags import Tags
from backend.models.Worker import Worker


def main():

    model = cp_model.CpModel()

    constraints = Constraints()

    kasjer = Tags("kasjer", "ten co sprzedaje")
    wozek_widlowy = Tags("wózek widłowy", "z uprawnieniami na wózek widłowy")
    kierownik = Tags("kierownik", "pan i władca")
    koordynator = Tags("koordynator", "logistyka tego typu")

    cashier1 = Worker("Adam", "Mada", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier2 = Worker("Bartek", "Ketrab", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier3 = Worker("Czesław", "Wałsecz", 20, "umowa zlecenie", 222, "123@wp.pl")

    cashier1.add_tag(kasjer)
    cashier2.add_tag(kasjer)
    cashier3.add_tag(kasjer)

    wozkowy = Worker("Damian", "Naimad", 20, "umowa zlecenie", 222, "123@wp.pl")
    wozkowy.add_tag(wozek_widlowy)

    manager = Worker("Edyta", "Atyde", 20, "umowa zlecenie", 222, "123@wp.pl")
    manager.add_tag(kierownik)

    coordinator = Worker("Felix", "Xilef", 20, "umowa zlecenie", 222, "123@wp.pl")
    coordinator.add_tag(koordynator)

    workers = [cashier1, cashier2, cashier3, wozkowy, manager, coordinator]
    for worker in workers:
        print(worker)


if __name__ == "__main__":
    main()