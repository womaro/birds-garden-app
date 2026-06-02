class BirdBiology {
  final String scientificName;
  final String polishName;
  final String size;
  final String diet;
  final String breeding;

  const BirdBiology({
    required this.scientificName,
    required this.polishName,
    required this.size,
    required this.diet,
    required this.breeding,
  });
}

const Map<String, BirdBiology> kBirdBiology = {
  'Eurasian Blackbird': BirdBiology(
    scientificName: 'Turdus merula',
    polishName: 'Kos',
    size: '24–25 cm',
    diet: 'dżdżownice, jagody, owady',
    breeding: 'marzec – lipiec',
  ),
  'Blue Tit': BirdBiology(
    scientificName: 'Cyanistes caeruleus',
    polishName: 'Sikora modra',
    size: '11–12 cm',
    diet: 'owady, nasiona, orzechy',
    breeding: 'kwiecień – czerwiec',
  ),
  'Great Tit': BirdBiology(
    scientificName: 'Parus major',
    polishName: 'Sikora bogatka',
    size: '13–15 cm',
    diet: 'owady, nasiona, orzechy',
    breeding: 'kwiecień – czerwiec',
  ),
  'Common Starling': BirdBiology(
    scientificName: 'Sturnus vulgaris',
    polishName: 'Szpak',
    size: '19–22 cm',
    diet: 'owady, dżdżownice, owoce',
    breeding: 'kwiecień – czerwiec',
  ),
  'European Robin': BirdBiology(
    scientificName: 'Erithacus rubecula',
    polishName: 'Rudzik',
    size: '12–14 cm',
    diet: 'owady, dżdżownice, jagody',
    breeding: 'marzec – lipiec',
  ),
  'House Sparrow': BirdBiology(
    scientificName: 'Passer domesticus',
    polishName: 'Wróbel',
    size: '14–16 cm',
    diet: 'nasiona, owady, resztki',
    breeding: 'kwiecień – sierpień',
  ),
  'Common Chaffinch': BirdBiology(
    scientificName: 'Fringilla coelebs',
    polishName: 'Zięba',
    size: '14–16 cm',
    diet: 'nasiona, owady',
    breeding: 'kwiecień – czerwiec',
  ),
  'European Greenfinch': BirdBiology(
    scientificName: 'Chloris chloris',
    polishName: 'Dzwoniec',
    size: '14–16 cm',
    diet: 'nasiona, jagody',
    breeding: 'kwiecień – sierpień',
  ),
  'Common Wood Pigeon': BirdBiology(
    scientificName: 'Columba palumbus',
    polishName: 'Grzywacz',
    size: '38–43 cm',
    diet: 'nasiona, zboże, liście',
    breeding: 'maj – wrzesień',
  ),
  'Eurasian Jay': BirdBiology(
    scientificName: 'Garrulus glandarius',
    polishName: 'Sójka',
    size: '32–35 cm',
    diet: 'żołędzie, owady, jaja',
    breeding: 'kwiecień – czerwiec',
  ),
  'Eurasian Magpie': BirdBiology(
    scientificName: 'Pica pica',
    polishName: 'Sroka',
    size: '40–51 cm',
    diet: 'owady, padlina, jaja, owoce',
    breeding: 'marzec – czerwiec',
  ),
  'Song Thrush': BirdBiology(
    scientificName: 'Turdus philomelos',
    polishName: 'Drozd śpiewak',
    size: '20–22 cm',
    diet: 'ślimaki, dżdżownice, jagody',
    breeding: 'marzec – lipiec',
  ),
  'Blackcap': BirdBiology(
    scientificName: 'Sylvia atricapilla',
    polishName: 'Kapturka',
    size: '13–15 cm',
    diet: 'owady, owoce, jagody',
    breeding: 'maj – lipiec',
  ),
  'Dunnock': BirdBiology(
    scientificName: 'Prunella modularis',
    polishName: 'Pokrzywnica',
    size: '13–14 cm',
    diet: 'owady, nasiona',
    breeding: 'kwiecień – lipiec',
  ),
  'Common Swift': BirdBiology(
    scientificName: 'Apus apus',
    polishName: 'Jerzyk',
    size: '16–17 cm',
    diet: 'owady (wyłącznie w locie)',
    breeding: 'czerwiec – lipiec',
  ),
};