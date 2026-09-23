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
      'अपने आस-पास की वस्तुओं का पता लगाने और सुनने के लिए कैमरा चालू करें';

  @override
  String get featureAnalyzerTitle => 'AI छवि विश्लेषक';

  @override
  String get featureAnalyzerDesc =>
      'दृश्य का विस्तृत आवाज़ विवरण पाने के लिए फोटो लें या चुनें';

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
  String get detectorPlaceholderMessage => 'लाइव कैमरा फीड यहां दिखाई देगा';

  @override
  String get startDetection => 'डिटेक्शन शुरू करें';

  @override
  String get stopDetection => 'डिटेक्शन रोकें';

  @override
  String get pauseDetection => 'डिटेक्शन रोकें';

  @override
  String get resumeDetection => 'डिटेक्शन फिर शुरू करें';

  @override
  String get cameraFeedSemantic => 'वस्तु संसूचन के लिए लाइव कैमरा फ़ीड';

  @override
  String detectedObjectAnnouncement(String label) {
    return '$label मिला';
  }

  @override
  String get detectorPausedStatus => 'डिटेक्शन रुका हुआ है';

  @override
  String get detectorReadyStatus => 'डिटेक्ट करने के लिए तैयार';

  @override
  String detectorObjectsCount(int count) {
    return '$count वस्तुएं संसूचित';
  }

  @override
  String detectorObjectsCountWithLatency(int count, int latency) {
    return '$count वस्तुएं | ${latency}ms';
  }

  @override
  String detectorPausedWithCount(int count) {
    return 'डिटेक्शन रुका हुआ ($count सहेजे गए)';
  }

  @override
  String get cameraUnavailable => 'इस डिवाइस पर कोई कैमरा उपलब्ध नहीं है।';

  @override
  String cameraErrorPrefix(String error) {
    return 'कैमरा त्रुटि: $error';
  }

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
  String get clickToStart => 'शुरू करने के लिए क्लिक करें';

  @override
  String get detectorCardSemantic =>
      'लाइव वस्तु संसूचक: अपने आस-पास की वस्तुओं का पता लगाने और सुनने के लिए कैमरा चालू करें। शुरू करने के लिए क्लिक करें।';

  @override
  String get analyzerCardSemantic =>
      'AI छवि विश्लेषक: दृश्य का विस्तृत आवाज़ विवरण पाने के लिए फोटो लें या चुनें। शुरू करने के लिए क्लिक करें।';

  @override
  String get emailNotProvided => 'कोई ईमेल नहीं दिया गया';

  @override
  String get loginHeaderSemantic => 'विज़न कम्पेनियन लोगो';

  @override
  String get passwordVisibilityToggleSemantic => 'पासवर्ड दृश्यता बदलें';

  @override
  String get signUpTitle => 'खाता बनाएं';

  @override
  String get signUpSubtitle =>
      'सहायक विज़न सहायता के लिए विज़न कम्पेनियन से जुड़ें';

  @override
  String get signUpButton => 'खाता बनाएं';

  @override
  String get nameLabel => 'पूरा नाम';

  @override
  String get nameHint => 'अपना पूरा नाम दर्ज करें';

  @override
  String get nameRequired => 'कृपया अपना नाम दर्ज करें';

  @override
  String get confirmPasswordLabel => 'पासवर्ड की पुष्टि करें';

  @override
  String get confirmPasswordHint => 'अपना पासवर्ड पुनः दर्ज करें';

  @override
  String get confirmPasswordRequired => 'कृपया पासवर्ड की पुष्टि करें';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get passwordTooShort => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है? साइन इन करें';

  @override
  String get dontHaveAccount => 'खाता नहीं है? साइन अप करें';

  @override
  String get switchToSignUpSemantic => 'साइन अप फॉर्म पर स्विच करें';

  @override
  String get switchToSignInSemantic => 'साइन इन फॉर्म पर स्विच करें';

  @override
  String get authErrorEmailAlreadyInUse =>
      'इस ईमेल पते से पहले से ही एक खाता मौजूद है।';

  @override
  String get authErrorWeakPassword =>
      'पासवर्ड बहुत कमजोर है। कृपया कम से कम 6 अक्षर उपयोग करें।';

  @override
  String get splashTitle => 'विज़न कम्पेनियन';

  @override
  String get splashSubtitle => 'एआई सहायक साथी';

  @override
  String get splashWelcomeText =>
      'स्वागत है! जारी रखने के लिए कृपया अपनी पसंदीदा भाषा चुनें।';

  @override
  String get selectLanguagePrompt => 'भाषा चुनें / Choose Language';

  @override
  String get continueButton => 'आगे बढ़ें';

  @override
  String get continueButtonSemantic => 'ऐप में आगे बढ़ें';

  @override
  String languageSelectedSemantic(String language) {
    return '$language चयनित है';
  }
}
