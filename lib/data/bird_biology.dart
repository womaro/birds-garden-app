import 'card_data.dart';

class BirdBiology {
  final String scientificName;
  final String polishName;
  final String size;
  final String diet;
  final String dietEn;
  final String breeding;
  final String breedingEn;
  final String gender;
  final String family;
  final int sizeStars;
  final int songStars;
  final int rarityStars;
  final CardRarity cardRarity;

  const BirdBiology({
    required this.scientificName,
    required this.polishName,
    required this.size,
    required this.diet,
    required this.dietEn,
    required this.breeding,
    required this.breedingEn,
    this.gender = 'm',
    required this.family,
    required this.sizeStars,
    required this.songStars,
    required this.rarityStars,
    required this.cardRarity,
  });
}

const Map<String, BirdBiology> kBirdBiology = {

  // ── Turdidae ──────────────────────────────────────────────────────────────

  'Eurasian Blackbird': BirdBiology(
    scientificName: 'Turdus merula', polishName: 'Kos', size: '24–25 cm',
    diet: 'dżdżownice, jagody, owady', dietEn: 'earthworms, berries, insects',
    breeding: 'marzec – lipiec', breedingEn: 'March – July',
    gender: 'm', family: 'Turdidae',
    sizeStars: 3, songStars: 5, rarityStars: 2, cardRarity: CardRarity.common,
  ),
  'Song Thrush': BirdBiology(
    scientificName: 'Turdus philomelos', polishName: 'Drozd śpiewak', size: '20–22 cm',
    diet: 'ślimaki, dżdżownice, jagody', dietEn: 'snails, earthworms, berries',
    breeding: 'marzec – lipiec', breedingEn: 'March – July',
    gender: 'm', family: 'Turdidae',
    sizeStars: 3, songStars: 5, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),
  'Fieldfare': BirdBiology(
    scientificName: 'Turdus pilaris', polishName: 'Kwiczoł', size: '25–27 cm',
    diet: 'jagody, dżdżownice, owady', dietEn: 'berries, earthworms, insects',
    breeding: 'kwiecień – lipiec', breedingEn: 'April – July',
    gender: 'm', family: 'Turdidae',
    sizeStars: 4, songStars: 3, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),

  // ── Paridae ───────────────────────────────────────────────────────────────

  'Blue Tit': BirdBiology(
    scientificName: 'Cyanistes caeruleus', polishName: 'Sikora modra', size: '11–12 cm',
    diet: 'owady, nasiona, orzechy', dietEn: 'insects, seeds, nuts',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'f', family: 'Paridae',
    sizeStars: 1, songStars: 3, rarityStars: 2, cardRarity: CardRarity.common,
  ),
  'Great Tit': BirdBiology(
    scientificName: 'Parus major', polishName: 'Sikora bogatka', size: '13–15 cm',
    diet: 'owady, nasiona, orzechy', dietEn: 'insects, seeds, nuts',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'f', family: 'Paridae',
    sizeStars: 2, songStars: 3, rarityStars: 2, cardRarity: CardRarity.common,
  ),
  'Long-tailed Tit': BirdBiology(
    scientificName: 'Aegithalos caudatus', polishName: 'Raniuszek', size: '13–15 cm',
    diet: 'owady, pająki, jaja owadów', dietEn: 'insects, spiders, insect eggs',
    breeding: 'marzec – maj', breedingEn: 'March – May',
    gender: 'm', family: 'Aegithalidae',
    sizeStars: 1, songStars: 2, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),
  'Marsh Tit': BirdBiology(
    scientificName: 'Poecile palustris', polishName: 'Sikora uboga', size: '11–13 cm',
    diet: 'nasiona, owady, jagody', dietEn: 'seeds, insects, berries',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'f', family: 'Paridae',
    sizeStars: 1, songStars: 3, rarityStars: 4, cardRarity: CardRarity.rare,
  ),

  // ── Fringillidae ──────────────────────────────────────────────────────────

  'Common Chaffinch': BirdBiology(
    scientificName: 'Fringilla coelebs', polishName: 'Zięba', size: '14–16 cm',
    diet: 'nasiona, owady', dietEn: 'seeds, insects',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'f', family: 'Fringillidae',
    sizeStars: 2, songStars: 4, rarityStars: 2, cardRarity: CardRarity.common,
  ),
  'European Greenfinch': BirdBiology(
    scientificName: 'Chloris chloris', polishName: 'Dzwoniec', size: '14–16 cm',
    diet: 'nasiona, jagody', dietEn: 'seeds, berries',
    breeding: 'kwiecień – sierpień', breedingEn: 'April – August',
    gender: 'm', family: 'Fringillidae',
    sizeStars: 2, songStars: 3, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),
  'European Goldfinch': BirdBiology(
    scientificName: 'Carduelis carduelis', polishName: 'Szczygieł', size: '12–13 cm',
    diet: 'nasiona ostów, szczawiu, babki', dietEn: 'thistle, sorrel and plantain seeds',
    breeding: 'kwiecień – sierpień', breedingEn: 'April – August',
    gender: 'm', family: 'Fringillidae',
    sizeStars: 2, songStars: 4, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),
  'Eurasian Bullfinch': BirdBiology(
    scientificName: 'Pyrrhula pyrrhula', polishName: 'Gil', size: '14–16 cm',
    diet: 'nasiona, pąki, jagody', dietEn: 'seeds, buds, berries',
    breeding: 'maj – lipiec', breedingEn: 'May – July',
    gender: 'm', family: 'Fringillidae',
    sizeStars: 2, songStars: 3, rarityStars: 4, cardRarity: CardRarity.rare,
  ),
  'Hawfinch': BirdBiology(
    scientificName: 'Coccothraustes coccothraustes', polishName: 'Grubodziób', size: '17–19 cm',
    diet: 'pestki wiśni, nasiona twardopestkowe', dietEn: 'cherry stones, hard seeds',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'm', family: 'Fringillidae',
    sizeStars: 3, songStars: 2, rarityStars: 5, cardRarity: CardRarity.epic,
  ),
  'Eurasian Siskin': BirdBiology(
    scientificName: 'Spinus spinus', polishName: 'Czyż', size: '11–12 cm',
    diet: 'nasiona olchy, brzozy, chwastów', dietEn: 'alder, birch and weed seeds',
    breeding: 'kwiecień – lipiec', breedingEn: 'April – July',
    gender: 'm', family: 'Fringillidae',
    sizeStars: 1, songStars: 4, rarityStars: 4, cardRarity: CardRarity.rare,
  ),
  'Common Linnet': BirdBiology(
    scientificName: 'Linaria cannabina', polishName: 'Makolągwa', size: '12–14 cm',
    diet: 'nasiona chwastów, owady', dietEn: 'weed seeds, insects',
    breeding: 'kwiecień – sierpień', breedingEn: 'April – August',
    gender: 'f', family: 'Fringillidae',
    sizeStars: 2, songStars: 4, rarityStars: 4, cardRarity: CardRarity.rare,
  ),
  'Common Redpoll': BirdBiology(
    scientificName: 'Acanthis flammea', polishName: 'Czeczotka', size: '11–14 cm',
    diet: 'nasiona brzozy, olchy, traw', dietEn: 'birch, alder and grass seeds',
    breeding: 'maj – lipiec', breedingEn: 'May – July',
    gender: 'f', family: 'Fringillidae',
    sizeStars: 1, songStars: 3, rarityStars: 5, cardRarity: CardRarity.epic,
  ),

  // ── Passeridae ────────────────────────────────────────────────────────────

  'House Sparrow': BirdBiology(
    scientificName: 'Passer domesticus', polishName: 'Wróbel', size: '14–16 cm',
    diet: 'nasiona, owady, resztki', dietEn: 'seeds, insects, scraps',
    breeding: 'kwiecień – sierpień', breedingEn: 'April – August',
    gender: 'm', family: 'Passeridae',
    sizeStars: 2, songStars: 1, rarityStars: 1, cardRarity: CardRarity.common,
  ),
  'Tree Sparrow': BirdBiology(
    scientificName: 'Passer montanus', polishName: 'Mazurek', size: '12–14 cm',
    diet: 'nasiona, owady, zboże', dietEn: 'seeds, insects, grain',
    breeding: 'kwiecień – lipiec', breedingEn: 'April – July',
    gender: 'm', family: 'Passeridae',
    sizeStars: 2, songStars: 2, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),

  // ── Sturnidae ─────────────────────────────────────────────────────────────

  'Common Starling': BirdBiology(
    scientificName: 'Sturnus vulgaris', polishName: 'Szpak', size: '19–22 cm',
    diet: 'owady, dżdżownice, owoce', dietEn: 'insects, earthworms, fruit',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'm', family: 'Sturnidae',
    sizeStars: 3, songStars: 4, rarityStars: 2, cardRarity: CardRarity.common,
  ),

  // ── Muscicapidae ──────────────────────────────────────────────────────────

  'European Robin': BirdBiology(
    scientificName: 'Erithacus rubecula', polishName: 'Rudzik', size: '12–14 cm',
    diet: 'owady, dżdżownice, jagody', dietEn: 'insects, earthworms, berries',
    breeding: 'marzec – lipiec', breedingEn: 'March – July',
    gender: 'm', family: 'Muscicapidae',
    sizeStars: 2, songStars: 5, rarityStars: 3, cardRarity: CardRarity.common,
  ),
  'Spotted Flycatcher': BirdBiology(
    scientificName: 'Muscicapa striata', polishName: 'Muchołówka szara', size: '13–15 cm',
    diet: 'owady (w locie)', dietEn: 'insects (caught in flight)',
    breeding: 'maj – sierpień', breedingEn: 'May – August',
    gender: 'f', family: 'Muscicapidae',
    sizeStars: 2, songStars: 2, rarityStars: 4, cardRarity: CardRarity.rare,
  ),
  'Common Redstart': BirdBiology(
    scientificName: 'Phoenicurus phoenicurus', polishName: 'Pleszka', size: '13–14 cm',
    diet: 'owady, pająki, jagody', dietEn: 'insects, spiders, berries',
    breeding: 'maj – lipiec', breedingEn: 'May – July',
    gender: 'f', family: 'Muscicapidae',
    sizeStars: 2, songStars: 4, rarityStars: 4, cardRarity: CardRarity.rare,
  ),

  // ── Sylviidae / Blackcap ───────────────────────────────────────────────────

  'Blackcap': BirdBiology(
    scientificName: 'Sylvia atricapilla', polishName: 'Kapturka', size: '13–15 cm',
    diet: 'owady, owoce, jagody', dietEn: 'insects, fruit, berries',
    breeding: 'maj – lipiec', breedingEn: 'May – July',
    gender: 'f', family: 'Sylviidae',
    sizeStars: 2, songStars: 5, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),

  // ── Prunellidae ───────────────────────────────────────────────────────────

  'Dunnock': BirdBiology(
    scientificName: 'Prunella modularis', polishName: 'Pokrzywnica', size: '13–14 cm',
    diet: 'owady, nasiona', dietEn: 'insects, seeds',
    breeding: 'kwiecień – lipiec', breedingEn: 'April – July',
    gender: 'f', family: 'Prunellidae',
    sizeStars: 2, songStars: 4, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),

  // ── Apodidae ──────────────────────────────────────────────────────────────

  'Common Swift': BirdBiology(
    scientificName: 'Apus apus', polishName: 'Jerzyk', size: '16–17 cm',
    diet: 'owady (wyłącznie w locie)', dietEn: 'insects (only in flight)',
    breeding: 'czerwiec – lipiec', breedingEn: 'June – July',
    gender: 'm', family: 'Apodidae',
    sizeStars: 3, songStars: 2, rarityStars: 4, cardRarity: CardRarity.rare,
  ),

  // ── Hirundinidae ──────────────────────────────────────────────────────────

  'Barn Swallow': BirdBiology(
    scientificName: 'Hirundo rustica', polishName: 'Dymówka', size: '14–19 cm',
    diet: 'owady (w locie)', dietEn: 'insects (caught in flight)',
    breeding: 'maj – sierpień', breedingEn: 'May – August',
    gender: 'f', family: 'Hirundinidae',
    sizeStars: 3, songStars: 3, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),

  // ── Corvidae ──────────────────────────────────────────────────────────────

  'Eurasian Jay': BirdBiology(
    scientificName: 'Garrulus glandarius', polishName: 'Sójka', size: '32–35 cm',
    diet: 'żołędzie, owady, jaja', dietEn: 'acorns, insects, eggs',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'f', family: 'Corvidae',
    sizeStars: 4, songStars: 2, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),
  'Eurasian Magpie': BirdBiology(
    scientificName: 'Pica pica', polishName: 'Sroka', size: '40–51 cm',
    diet: 'owady, padlina, jaja, owoce', dietEn: 'insects, carrion, eggs, fruit',
    breeding: 'marzec – czerwiec', breedingEn: 'March – June',
    gender: 'f', family: 'Corvidae',
    sizeStars: 4, songStars: 2, rarityStars: 2, cardRarity: CardRarity.common,
  ),
  'Jackdaw': BirdBiology(
    scientificName: 'Corvus monedula', polishName: 'Kawka', size: '30–34 cm',
    diet: 'owady, nasiona, padlina', dietEn: 'insects, seeds, carrion',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'f', family: 'Corvidae',
    sizeStars: 4, songStars: 2, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),
  'Hooded Crow': BirdBiology(
    scientificName: 'Corvus cornix', polishName: 'Wrona siwa', size: '44–51 cm',
    diet: 'wszystkożerna', dietEn: 'omnivorous',
    breeding: 'marzec – czerwiec', breedingEn: 'March – June',
    gender: 'f', family: 'Corvidae',
    sizeStars: 5, songStars: 1, rarityStars: 2, cardRarity: CardRarity.common,
  ),

  // ── Columbidae ────────────────────────────────────────────────────────────

  'Common Wood Pigeon': BirdBiology(
    scientificName: 'Columba palumbus', polishName: 'Grzywacz', size: '38–43 cm',
    diet: 'nasiona, zboże, liście', dietEn: 'seeds, grain, leaves',
    breeding: 'maj – wrzesień', breedingEn: 'May – September',
    gender: 'm', family: 'Columbidae',
    sizeStars: 5, songStars: 2, rarityStars: 2, cardRarity: CardRarity.common,
  ),
  'Collared Dove': BirdBiology(
    scientificName: 'Streptopelia decaocto', polishName: 'Sierpówka', size: '31–33 cm',
    diet: 'nasiona, zboże, owoce', dietEn: 'seeds, grain, fruit',
    breeding: 'marzec – październik', breedingEn: 'March – October',
    gender: 'f', family: 'Columbidae',
    sizeStars: 4, songStars: 2, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),

  // ── Troglodytidae ─────────────────────────────────────────────────────────

  'Eurasian Wren': BirdBiology(
    scientificName: 'Troglodytes troglodytes', polishName: 'Strzyżyk', size: '9–10 cm',
    diet: 'owady, pająki, larwy', dietEn: 'insects, spiders, larvae',
    breeding: 'kwiecień – lipiec', breedingEn: 'April – July',
    gender: 'm', family: 'Troglodytidae',
    sizeStars: 1, songStars: 5, rarityStars: 3, cardRarity: CardRarity.uncommon,
  ),

  // ── Sittidae ──────────────────────────────────────────────────────────────

  'Eurasian Nuthatch': BirdBiology(
    scientificName: 'Sitta europaea', polishName: 'Kowalik', size: '12–14 cm',
    diet: 'owady, orzechy, nasiona', dietEn: 'insects, nuts, seeds',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'm', family: 'Sittidae',
    sizeStars: 2, songStars: 4, rarityStars: 4, cardRarity: CardRarity.rare,
  ),

  // ── Certhiidae ────────────────────────────────────────────────────────────

  'Short-toed Treecreeper': BirdBiology(
    scientificName: 'Certhia brachydactyla', polishName: 'Pełzacz ogrodowy', size: '12–13 cm',
    diet: 'owady, pająki, larwy z kory', dietEn: 'insects, spiders, bark larvae',
    breeding: 'kwiecień – czerwiec', breedingEn: 'April – June',
    gender: 'm', family: 'Certhiidae',
    sizeStars: 1, songStars: 3, rarityStars: 4, cardRarity: CardRarity.rare,
  ),

  // ── Emberizidae ───────────────────────────────────────────────────────────

  'Yellowhammer': BirdBiology(
    scientificName: 'Emberiza citrinella', polishName: 'Trznadel', size: '15–17 cm',
    diet: 'nasiona traw, owady', dietEn: 'grass seeds, insects',
    breeding: 'kwiecień – sierpień', breedingEn: 'April – August',
    gender: 'm', family: 'Emberizidae',
    sizeStars: 2, songStars: 4, rarityStars: 4, cardRarity: CardRarity.rare,
  ),
};