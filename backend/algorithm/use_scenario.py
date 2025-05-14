from backend.models.Constraints import Constraints
from backend.models.Tags import Tags
from backend.models.Worker import Worker


def setup_scenario():
    kasjer = Tags("kasjer", "ten co sprzedaje")
    wozek_widlowy = Tags("wózek widłowy", "z uprawnieniami na wózek widłowy")
    kierownik = Tags("kierownik", "pan i władca")
    koordynator = Tags("koordynator", "logistyka tego typu")
    default = Tags("default", "no special tags")

    tags = [kasjer, wozek_widlowy, kierownik, koordynator, default]

    cashier1 = Worker("Monika", "Kinom", "female",20, "umowa zlecenie", 222, "123@wp.pl")
    cashier2 = Worker("Monisia", "Isinom", "female",20, "umowa zlecenie", 222, "123@wp.pl")
    cashier3 = Worker("Kasia", "Isak", "female",20, "umowa zlecenie", 222, "123@wp.pl")
    cashier4 = Worker("Basia", "Isab", "female",20, "umowa zlecenie", 222, "123@wp.pl")
    cashier5 = Worker("Asia", "Isa", "female",20, "umowa zlecenie", 222, "123@wp.pl")
    cashier6 = Worker("Iwona", "Nowi", "female",20, "umowa zlecenie", 222, "123@wp.pl")
    cashier7 = Worker("Anna", "Nna", "female",20, "umowa zlecenie", 222, "123@wp.pl")
    cashier8 = Worker("Agnieszka", "Kzseinga", "female",20, "umowa zlecenie", 222, "123@wp.pl")


    cashier1.add_tag(kasjer)
    cashier2.add_tag(kasjer)
    cashier3.add_tag(kasjer)
    cashier4.add_tag(kasjer)
    cashier5.add_tag(kasjer)
    cashier6.add_tag(kasjer)
    cashier7.add_tag(kasjer)
    cashier8.add_tag(kasjer)

    mrowka1 = Worker("Marcin", "Nicram", "male",20, "umowa zlecenie", 222, "123@wp.pl")
    mrowka2 = Worker("Bartłomiej", "Jeimołtrab", "male",20, "umowa zlecenie", 222, "123@wp.pl")
    mrowka3 = Worker("Paweł", "Łewap", "male",20, "umowa zlecenie", 222, "123@wp.pl")
    mrowka4 = Worker("Klaudiusz", "Zsuidualk", "male",20, "umowa zlecenie", 222, "123@wp.pl")
    mrowka5 = Worker("Tomasz", "Zsamot", "male",20, "umowa zlecenie", 222, "123@wp.pl")
    mrowka6 = Worker("Andrzej", "Jezrdna", "male",20, "umowa zlecenie", 222, "123@wp.pl")

    mrowka1.add_tag(wozek_widlowy)
    mrowka2.add_tag(wozek_widlowy)
    mrowka6.add_tag(wozek_widlowy)

    mrowka3.add_tag(default)
    mrowka4.add_tag(default)
    mrowka5.add_tag(default)


    manager1 = Worker("Bartosz", "Kierowniczy", "male", 20, "umowa zlecenie", 222, "123@wp.pl")
    vice_manager1 = Worker("Katarzyna", "PrawieKierownicza", "female", 20, "umowa zlecenie", 222, "123@wp.pl")
    vice_manager2 = Worker("Krzysztof", "PrawieKierownik", "male", 20, "umowa zlecenie", 222, "123@wp.pl")

    manager1.add_tag(kierownik)
    vice_manager1.add_tag(kierownik)
    vice_manager2.add_tag(kierownik)

    coordinator1 = Worker("Justyna", "Nytsuj", "female", 20, "umowa zlecenie", 222, "123@wp.pl")
    coordinator2 = Worker("Mateusz", "Zsuetam", "male", 20, "umowa zlecenie", 222, "123@wp.pl")

    coordinator1.add_tag(koordynator)
    coordinator2.add_tag(koordynator)

    workers = [cashier1, cashier2, cashier3, cashier4, cashier5, cashier6, cashier7, cashier8,  # kobiety - grupa B
               mrowka1, mrowka2, mrowka6, mrowka4, mrowka5, mrowka3,   # mężczyźni - grupa B
               manager1, vice_manager1, vice_manager2,
               coordinator1, coordinator2
               ]

    constraints = Constraints()

    return constraints, workers, tags