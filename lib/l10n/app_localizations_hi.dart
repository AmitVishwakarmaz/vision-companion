// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'विज़न कम्पेनियन';

  @override
  String get homeTitle => 'होम';

  @override
  String get welcomeMessage => 'विज़न कम्पेनियन में आपका स्वागत है';

  @override
  String get subtitleAssistive => 'सशक्त सहायक दृश्य बुद्धिमत्ता';

  @override
  String get featureDetectorTitle => 'लाइव वस्तु संसूचक';

  @override
  String get featureDetectorDesc =>
      'TFLite के माध्यम से रीयल-टाइम ऑन-डिवाइस ऑब्जेक्ट डिटेक्शन';

  @override
  String get featureAnalyzerTitle => 'AI छवि विश्लेषक';

  @override
  String get featureAnalyzerDesc => 'AI द्वारा गहन दृश्य समझ और विवरण';

  @override
  String get featureSettingsTitle => 'सेटिंग्स और प्रोफ़ाइल';

  @override
  String get featureSettingsDesc =>
      'भाषा प्राथमिकताएं, थीम और प्रोफ़ाइल प्रबंधित करें';

  @override
  String get loginTitle => 'साइन इन करें';

  @override
  String get loginSubtitle => 'अपने सहायक विज़न साथी तक पहुंचें';

  @override
  String get emailLabel => 'ईमेल पता';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get emailHint => 'अपना ईमेल दर्ज करें';

  @override
  String get passwordHint => 'अपना पासवर्ड दर्ज करें';

  @override
  String get emailRequired => 'कृपया अपना ईमेल दर्ज करें';

  @override
  String get passwordRequired => 'कृपया अपना पासवर्ड दर्ज करें';

  @override
  String get signInButton => 'साइन इन';

  @override
  String get signInWithGoogle => 'गूगल के साथ जारी रखें';

  @override
  String get signOutButton => 'साइन आउट';

  @override
  String get detectorScreenTitle => 'रीयल-टाइम ऑब्जेक्ट डिटेक्टर';

  @override
  String get detectorPlaceholderMessage =>
      'TFLite लाइव कैमरा फीड यहां दिखाई देगा';

  @override
  String get startDetection => 'डिटेक्शन शुरू करें';

  @override
  String get stopDetection => 'डिटेक्शन रोकें';

  @override
  String get analyzerScreenTitle => 'AI दृश्य विश्लेषक';

  @override
  String get analyzerPlaceholderMessage =>
      'विश्लेषण के लिए एक छवि चुनें या फोटो लें';

  @override
  String get pickImageButton => 'गैलरी से चुनें';

  @override
  String get captureImageButton => 'फोटो खींचें';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get languageSetting => 'भाषा';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी (Hindi)';

  @override
  String get themeSetting => 'थीम मोड';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get themeSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get profileSection => 'उपयोगकर्ता प्रोफ़ाइल';

  @override
  String get anonymousUser => 'अतिथि उपयोगकर्ता';

  @override
  String get authErrorUserNotFound =>
      'इस ईमेल पते से कोई उपयोगकर्ता नहीं मिला।';

  @override
  String get authErrorWrongPassword => 'गलत पासवर्ड। कृपया पुनः प्रयास करें।';

  @override
  String get authErrorInvalidEmail => 'ईमेल पता अमान्य है।';

  @override
  String get authErrorUserDisabled => 'यह खाता अक्षम कर दिया गया है।';

  @override
  String get authErrorTooManyRequests =>
      'बहुत सारे असफल प्रयास। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get authErrorNetworkFailed =>
      'नेटवर्क त्रुटि। कृपया अपना इंटरनेट कनेक्शन जांचें।';

  @override
  String get authErrorGoogleCancelled => 'गूगल साइन-इन रद्द कर दिया गया।';

  @override
  String get authErrorGeneric =>
      'प्रमाणीकरण विफल रहा। कृपया अपनी जानकारी जांचें।';

  @override
  String greetingWithName(String name) {
    return 'नमस्ते, $name!';
  }

  @override
  String profileSemanticLabel(String name) {
    return 'प्रोफ़ाइल: $name, मेनू खोलने के लिए टैप करें';
  }

  @override
  String get profileMenuTitle => 'खाता प्रोफ़ाइल';

  @override
  String get profileMenuClose => 'प्रोफ़ाइल मेनू बंद करें';

  @override
  String get startFeatureButton => 'शुरू करें';

  @override
  String get detectorCardSemantic =>
      'लाइव वस्तु संसूचक: TFLite के माध्यम से रीयल-टाइम ऑन-डिवाइस ऑब्जेक्ट डिटेक्शन। शुरू करने के लिए दो बार टैप करें।';

  @override
  String get analyzerCardSemantic =>
      'AI छवि विश्लेषक: AI द्वारा गहन दृश्य समझ और विवरण। शुरू करने के लिए दो बार टैप करें।';

  @override
  String get emailNotProvided => 'कोई ईमेल नहीं दिया गया';

  @override
  String get loginHeaderSemantic => 'विज़न कम्पेनियन लोगो';

  @override
  String get passwordVisibilityToggleSemantic => 'पासवर्ड दृश्यता बदलें';
}
