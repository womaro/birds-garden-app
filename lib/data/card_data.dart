import 'package:flutter/material.dart';

// ── Rzadkość ───────────────────────────────────────────────────────────────

enum CardRarity { common, uncommon, rare, epic, legendary }

const kRarityLabel = {
  CardRarity.common:    'Pospolity',
  CardRarity.uncommon:  'Zwykły',
  CardRarity.rare:      'Rzadki',
  CardRarity.epic:      'Epicki',
  CardRarity.legendary: 'Legendarny',
};

const kRarityLabelEn = {
  CardRarity.common:    'Common',
  CardRarity.uncommon:  'Uncommon',
  CardRarity.rare:      'Rare',
  CardRarity.epic:      'Epic',
  CardRarity.legendary: 'Legendary',
};

const kRarityColor = {
  CardRarity.common:    Color(0xFF9E9E9E),
  CardRarity.uncommon:  Color(0xFF43A047),
  CardRarity.rare:      Color(0xFF1E88E5),
  CardRarity.epic:      Color(0xFF8E24AA),
  CardRarity.legendary: Color(0xFFFFA000),
};

// ── Kolory rodzin taksonomicznych ──────────────────────────────────────────

const kFamilyGradient = {
  'Turdidae':      [Color(0xFF795548), Color(0xFF3E2723)],
  'Paridae':       [Color(0xFF1565C0), Color(0xFF0D47A1)],
  'Fringillidae':  [Color(0xFFE65100), Color(0xFFBF360C)],
  'Passeridae':    [Color(0xFF6D4C41), Color(0xFF4E342E)],
  'Sturnidae':     [Color(0xFF4A148C), Color(0xFF1A237E)],
  'Muscicapidae':  [Color(0xFFB71C1C), Color(0xFF7F0000)],
  'Sylviidae':     [Color(0xFF1B5E20), Color(0xFF33691E)],
  'Prunellidae':   [Color(0xFF546E7A), Color(0xFF263238)],
  'Corvidae':      [Color(0xFF212121), Color(0xFF37474F)],
  'Columbidae':    [Color(0xFF546E7A), Color(0xFF263238)],
  'Apodidae':      [Color(0xFF0D47A1), Color(0xFF006064)],
  'Hirundinidae':  [Color(0xFF006064), Color(0xFF004D40)],
  'Aegithalidae':  [Color(0xFFAD1457), Color(0xFF880E4F)],
  'Sittidae':      [Color(0xFF00695C), Color(0xFF004D40)],
  'Emberizidae':   [Color(0xFFF57F17), Color(0xFFE65100)],
  'Troglodytidae': [Color(0xFF5D4037), Color(0xFF3E2723)],
  'Certhiidae':    [Color(0xFF558B2F), Color(0xFF33691E)],
};

const Map<String, String> kFamilyNamePl = {
  'Turdidae'      : 'Drozdowate',
  'Paridae'       : 'Sikorowate',
  'Aegithalidae'  : 'Raniuszkowate',
  'Fringillidae'  : 'Łuszczaki',
  'Passeridae'    : 'Wróblowate',
  'Sturnidae'     : 'Szpakowate',
  'Muscicapidae'  : 'Muchołówkowate',
  'Sylviidae'     : 'Pokrzewkowate',
  'Prunellidae'   : 'Płoczkówkowate',
  'Apodidae'      : 'Jerzykowate',
  'Hirundinidae'  : 'Jaskółkowate',
  'Corvidae'      : 'Krukowate',
  'Columbidae'    : 'Gołębiowate',
  'Troglodytidae' : 'Strzyżykowate',
  'Sittidae'      : 'Kowalikowe',
  'Certhiidae'    : 'Pełzaczkowate',
  'Emberizidae'   : 'Trznadlowate',
};

const Map<String, String> kFamilyNameEn = {
  'Turdidae'      : 'Thrushes',
  'Paridae'       : 'Tits',
  'Aegithalidae'  : 'Long-tailed Tits',
  'Fringillidae'  : 'Finches',
  'Passeridae'    : 'Sparrows',
  'Sturnidae'     : 'Starlings',
  'Muscicapidae'  : 'Flycatchers',
  'Sylviidae'     : 'Warblers',
  'Prunellidae'   : 'Accentors',
  'Apodidae'      : 'Swifts',
  'Hirundinidae'  : 'Swallows',
  'Corvidae'      : 'Corvids',
  'Columbidae'    : 'Pigeons & Doves',
  'Troglodytidae' : 'Wrens',
  'Sittidae'      : 'Nuthatches',
  'Certhiidae'    : 'Treecreepers',
  'Emberizidae'   : 'Buntings',
};

List<Color> familyGradient(String family) =>
    kFamilyGradient[family] ??
    [const Color(0xFF0F6E56), const Color(0xFF085041)];

// ── Dostępne assety ────────────────────────────────────────────────────────

// Wszystkie 35 SVG dostępne
const kAvailableSvgs = {
  'Eurasian Blackbird', 'Blue Tit', 'Great Tit', 'Common Starling',
  'European Robin', 'House Sparrow', 'Common Chaffinch',
  'European Greenfinch', 'Common Wood Pigeon', 'Eurasian Jay',
  'Eurasian Magpie', 'Song Thrush', 'Blackcap', 'Dunnock', 'Common Swift',
  'Eurasian Wren', 'Long-tailed Tit', 'Eurasian Nuthatch',
  'Short-toed Treecreeper', 'European Goldfinch', 'Common Linnet',
  'Eurasian Bullfinch', 'Hawfinch', 'Yellowhammer', 'Spotted Flycatcher',
  'Common Redstart', 'Barn Swallow', 'Hooded Crow', 'Jackdaw',
  'Collared Dove', 'Eurasian Siskin', 'Fieldfare', 'Tree Sparrow',
  'Common Redpoll', 'Marsh Tit',
};

// Zdjęcia z ogrodu — na razie tylko testowe, rozszerzy się po instalacji kamery
const kAvailablePhotos = {
  'Eurasian Blackbird',   // ← testowe z unsplash
};

String birdSvgPath(String species) =>
    'assets/birds/${species.toLowerCase().replaceAll(' ', '_')}.svg';

String birdPhotoPath(String species) =>
    'assets/photos/${species.toLowerCase().replaceAll(' ', '_')}.jpg';

// ── Pełna lista polskich ptaków ogrodowych (35) ────────────────────────────

const kAllPolishGardenBirds = [
  'Eurasian Blackbird', 'Blue Tit', 'Great Tit', 'Common Starling',
  'European Robin', 'House Sparrow', 'Common Chaffinch',
  'European Greenfinch', 'Common Wood Pigeon', 'Eurasian Jay',
  'Eurasian Magpie', 'Song Thrush', 'Blackcap', 'Dunnock', 'Common Swift',
  'Eurasian Wren', 'Long-tailed Tit', 'Eurasian Nuthatch',
  'Short-toed Treecreeper', 'European Goldfinch', 'Common Linnet',
  'Eurasian Bullfinch', 'Hawfinch', 'Yellowhammer', 'Spotted Flycatcher',
  'Common Redstart', 'Barn Swallow', 'Hooded Crow', 'Jackdaw',
  'Collared Dove', 'Eurasian Siskin', 'Fieldfare', 'Tree Sparrow',
  'Common Redpoll', 'Marsh Tit',
];
