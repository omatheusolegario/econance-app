import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @screenwelcomepage.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get screenwelcomepage;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeMessage;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @carousel1.
  ///
  /// In en, this message translates to:
  /// **'The ultimate and most comprehensive financial management app.'**
  String get carousel1;

  /// No description provided for @carousel2.
  ///
  /// In en, this message translates to:
  /// **'Access powerful insights about your money and make smarter decisions every day.'**
  String get carousel2;

  /// No description provided for @carousel3.
  ///
  /// In en, this message translates to:
  /// **'Take full control of your finances in the palm of your hand, wherever you are.'**
  String get carousel3;

  /// No description provided for @screenlogin.
  ///
  /// In en, this message translates to:
  /// **''**
  String get screenlogin;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to Econance'**
  String get welcomeBack;

  /// No description provided for @phonenumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phonenumber;

  /// No description provided for @emailaddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailaddress;

  /// No description provided for @emailinput.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailinput;

  /// No description provided for @phoneinput.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneinput;

  /// No description provided for @templateemail.
  ///
  /// In en, this message translates to:
  /// **'example@gmail.com'**
  String get templateemail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordinput.
  ///
  /// In en, this message translates to:
  /// **'•••••••••'**
  String get passwordinput;

  /// No description provided for @forgotpassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotpassword;

  /// No description provided for @snackloginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login was successful!'**
  String get snackloginSuccess;

  /// No description provided for @snackloginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get snackloginError;

  /// No description provided for @emailverification.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent. Please check your email'**
  String get emailverification;

  /// No description provided for @iverified.
  ///
  /// In en, this message translates to:
  /// **'I have verified'**
  String get iverified;

  /// No description provided for @resendverification.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendverification;

  /// No description provided for @notverified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet!'**
  String get notverified;

  /// No description provided for @resendwarning.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent!'**
  String get resendwarning;

  /// No description provided for @fullname.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullname;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit app?'**
  String get exitAppTitle;

  /// No description provided for @exitAppContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit Econance?'**
  String get exitAppContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @separateExpensesInto.
  ///
  /// In en, this message translates to:
  /// **'Separate your expenses into'**
  String get separateExpensesInto;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @revenues.
  ///
  /// In en, this message translates to:
  /// **'Revenues'**
  String get revenues;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @exampleFoodHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Food'**
  String get exampleFoodHint;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @selectCategoryType.
  ///
  /// In en, this message translates to:
  /// **'Select a category type'**
  String get selectCategoryType;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields first'**
  String get pleaseFillAllFields;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @chooseCategoryDateRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Choose category, date and recurrence'**
  String get chooseCategoryDateRecurrence;

  /// No description provided for @isThisRecurrent.
  ///
  /// In en, this message translates to:
  /// **'Is this recurrent?'**
  String get isThisRecurrent;

  /// No description provided for @isRecurrent.
  ///
  /// In en, this message translates to:
  /// **'Is recurrent?'**
  String get isRecurrent;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @newRevenue.
  ///
  /// In en, this message translates to:
  /// **'New Revenue'**
  String get newRevenue;

  /// No description provided for @newInvestments.
  ///
  /// In en, this message translates to:
  /// **'New Investments'**
  String get newInvestments;

  /// No description provided for @newInvestmentTypes.
  ///
  /// In en, this message translates to:
  /// **'New Investments Type'**
  String get newInvestmentTypes;

  /// No description provided for @removeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLabel;

  /// No description provided for @noUserFoundWithThisEmail.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email'**
  String get noUserFoundWithThisEmail;

  /// No description provided for @inviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invite sent'**
  String get inviteSent;

  /// No description provided for @userAlreadyInFamily.
  ///
  /// In en, this message translates to:
  /// **'User already in a family'**
  String get userAlreadyInFamily;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @inviteMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite member'**
  String get inviteMemberTitle;

  /// No description provided for @memberEmailHint.
  ///
  /// In en, this message translates to:
  /// **'member@example.com'**
  String get memberEmailHint;

  /// No description provided for @participateInExistingFamilyWith.
  ///
  /// In en, this message translates to:
  /// **'Participate in an existing family with'**
  String get participateInExistingFamilyWith;

  /// No description provided for @inviteNewMembersToYourFamilyWith.
  ///
  /// In en, this message translates to:
  /// **'Invite new members to your family with'**
  String get inviteNewMembersToYourFamilyWith;

  /// No description provided for @invites.
  ///
  /// In en, this message translates to:
  /// **'Invites'**
  String get invites;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @noPendingInvites.
  ///
  /// In en, this message translates to:
  /// **'No pending invites'**
  String get noPendingInvites;

  /// No description provided for @familyNameCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Family name can\'t be empty'**
  String get familyNameCantBeEmpty;

  /// No description provided for @createFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Family'**
  String get createFamilyTitle;

  /// No description provided for @familyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyNameHint;

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get changeRole;

  /// No description provided for @viewMemberGraphs.
  ///
  /// In en, this message translates to:
  /// **'View member graphs'**
  String get viewMemberGraphs;

  /// No description provided for @removeFromFamily.
  ///
  /// In en, this message translates to:
  /// **'Remove from family'**
  String get removeFromFamily;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member?'**
  String get removeMemberTitle;

  /// No description provided for @removeMemberContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member?'**
  String get removeMemberContent;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @waitingResponseFrom.
  ///
  /// In en, this message translates to:
  /// **'Waiting response from'**
  String get waitingResponseFrom;

  /// No description provided for @declinedInvite.
  ///
  /// In en, this message translates to:
  /// **'Declined invite'**
  String get declinedInvite;

  /// No description provided for @acceptedInvite.
  ///
  /// In en, this message translates to:
  /// **'Accepted invite'**
  String get acceptedInvite;

  /// No description provided for @deletedInvite.
  ///
  /// In en, this message translates to:
  /// **'Deleted Invite'**
  String get deletedInvite;

  /// No description provided for @leaveFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Family?'**
  String get leaveFamilyTitle;

  /// No description provided for @leaveFamilyContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this family?'**
  String get leaveFamilyContent;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @deleteFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Family?'**
  String get deleteFamilyTitle;

  /// No description provided for @deleteFamilyContent.
  ///
  /// In en, this message translates to:
  /// **'You are the last one in the family, leaving will delete it.\nAre you sure?'**
  String get deleteFamilyContent;

  /// No description provided for @deleteFamily.
  ///
  /// In en, this message translates to:
  /// **'   Delete Family   '**
  String get deleteFamily;

  /// No description provided for @leaveFamily.
  ///
  /// In en, this message translates to:
  /// **'Leave Family'**
  String get leaveFamily;

  /// No description provided for @graphsManageIntro.
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll manage'**
  String get graphsManageIntro;

  /// No description provided for @finances.
  ///
  /// In en, this message translates to:
  /// **'Finances'**
  String get finances;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading data.'**
  String get errorLoadingData;

  /// No description provided for @noInformationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No information available at the moment.'**
  String get noInformationAvailable;

  /// No description provided for @sensitiveDataHidden.
  ///
  /// In en, this message translates to:
  /// **'Sensitive data hidden'**
  String get sensitiveDataHidden;

  /// No description provided for @balanceHidden.
  ///
  /// In en, this message translates to:
  /// **'The balance is R\$•••••'**
  String get balanceHidden;

  /// No description provided for @balanceIs.
  ///
  /// In en, this message translates to:
  /// **'The balance is'**
  String get balanceIs;

  /// No description provided for @checkRevenuesExpenses.
  ///
  /// In en, this message translates to:
  /// **'Want to check on revenues/expenses?'**
  String get checkRevenuesExpenses;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @noExpensesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded.'**
  String get noExpensesRecorded;

  /// No description provided for @noRevenueRecorded.
  ///
  /// In en, this message translates to:
  /// **'No revenues recorded.'**
  String get noRevenueRecorded;

  /// No description provided for @manageYourCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage your categories'**
  String get manageYourCategories;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @manageYourInvestments.
  ///
  /// In en, this message translates to:
  /// **'Manage your investments'**
  String get manageYourInvestments;

  /// No description provided for @manageYourInvestmentTypes.
  ///
  /// In en, this message translates to:
  /// **'Manage your investment types'**
  String get manageYourInvestmentTypes;

  /// No description provided for @noInvestmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No investments found'**
  String get noInvestmentsFound;

  /// No description provided for @investmentsByType.
  ///
  /// In en, this message translates to:
  /// **'Investments by Type'**
  String get investmentsByType;

  /// No description provided for @trackManageInvestments.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your investments'**
  String get trackManageInvestments;

  /// No description provided for @yourInvestments.
  ///
  /// In en, this message translates to:
  /// **'Your Investments'**
  String get yourInvestments;

  /// No description provided for @noInvestmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No investments yet'**
  String get noInvestmentsYet;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @searchInvestmentTypesHint.
  ///
  /// In en, this message translates to:
  /// **'Search investment types...'**
  String get searchInvestmentTypesHint;

  /// No description provided for @noTypesFoundAddOne.
  ///
  /// In en, this message translates to:
  /// **'No types found. Add one first!'**
  String get noTypesFoundAddOne;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @organizeYourInvestmentsBy.
  ///
  /// In en, this message translates to:
  /// **'Organize your investments by'**
  String get organizeYourInvestmentsBy;

  /// No description provided for @investmentTypes.
  ///
  /// In en, this message translates to:
  /// **'Investment Types'**
  String get investmentTypes;

  /// No description provided for @noInvestmentTypesYet.
  ///
  /// In en, this message translates to:
  /// **'No investment types yet'**
  String get noInvestmentTypesYet;

  /// No description provided for @balanceOverTime.
  ///
  /// In en, this message translates to:
  /// **'Balance Over Time'**
  String get balanceOverTime;

  /// No description provided for @revenueOverTime.
  ///
  /// In en, this message translates to:
  /// **'Revenue Over Time'**
  String get revenueOverTime;

  /// No description provided for @expensesOverTime.
  ///
  /// In en, this message translates to:
  /// **'Expenses Over Time'**
  String get expensesOverTime;

  /// No description provided for @investmentsOverTime.
  ///
  /// In en, this message translates to:
  /// **'Investments Over Time'**
  String get investmentsOverTime;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @revenuesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Revenues by Category'**
  String get revenuesByCategory;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @investmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investmentsLabel;

  /// No description provided for @stepFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get stepFullName;

  /// No description provided for @stepEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get stepEmail;

  /// No description provided for @stepPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get stepPhone;

  /// No description provided for @stepPasswordVerification.
  ///
  /// In en, this message translates to:
  /// **'Password & Verification'**
  String get stepPasswordVerification;

  /// No description provided for @enterFullNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get enterFullNameError;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Error while registering'**
  String get registrationError;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get weakPassword;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified.'**
  String get emailNotVerified;

  /// No description provided for @enterFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullNameLabel;

  /// No description provided for @enterEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmailLabel;

  /// No description provided for @enterPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone'**
  String get enterPhoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+55 11 99999-9999'**
  String get phoneHint;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete your registration'**
  String get completeRegistration;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your email'**
  String get passwordResetSent;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @noUserFoundForEmail.
  ///
  /// In en, this message translates to:
  /// **'No user found for that email'**
  String get noUserFoundForEmail;

  /// No description provided for @forgotPasswordAppBar.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordAppBar;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @recoverAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recover access to your account'**
  String get recoverAccessSubtitle;

  /// No description provided for @resetInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password'**
  String get resetInstruction;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @giveYourCategoryAName.
  ///
  /// In en, this message translates to:
  /// **'Give your category a name'**
  String get giveYourCategoryAName;

  /// No description provided for @chooseTheType.
  ///
  /// In en, this message translates to:
  /// **'Choose the type'**
  String get chooseTheType;

  /// No description provided for @isYourCategoryAnExpenseOrRevenue.
  ///
  /// In en, this message translates to:
  /// **'Is your category an expense or a revenue?'**
  String get isYourCategoryAnExpenseOrRevenue;

  /// No description provided for @categorySuccessfullyAdded.
  ///
  /// In en, this message translates to:
  /// **'Category successfully added!'**
  String get categorySuccessfullyAdded;

  /// No description provided for @addAnotherCategory.
  ///
  /// In en, this message translates to:
  /// **'   Add another category   '**
  String get addAnotherCategory;

  /// No description provided for @typeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Type updated'**
  String get typeUpdated;

  /// No description provided for @typeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Type deleted'**
  String get typeDeleted;

  /// No description provided for @exampleStocksHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stocks'**
  String get exampleStocksHint;

  /// No description provided for @investmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Investment Info'**
  String get investmentInfo;

  /// No description provided for @enterInvestmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter the basic information of your investment.'**
  String get enterInvestmentInfo;

  /// No description provided for @exampleBitcoinHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bitcoin'**
  String get exampleBitcoinHint;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get selectType;

  /// No description provided for @financialInfo.
  ///
  /// In en, this message translates to:
  /// **'Financial Info'**
  String get financialInfo;

  /// No description provided for @enterFinancialInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter investment value, target and rate.'**
  String get enterFinancialInfo;

  /// No description provided for @investedValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Invested Value (R\$)'**
  String get investedValueLabel;

  /// No description provided for @targetValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Value (R\$)'**
  String get targetValueLabel;

  /// No description provided for @rateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate (%)'**
  String get rateLabel;

  /// No description provided for @statusNotes.
  ///
  /// In en, this message translates to:
  /// **'Status & Notes'**
  String get statusNotes;

  /// No description provided for @selectStatusDateAndNotes.
  ///
  /// In en, this message translates to:
  /// **'Select status, date and add optional notes.'**
  String get selectStatusDateAndNotes;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get selectStatus;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @optionalObservations.
  ///
  /// In en, this message translates to:
  /// **'Optional observations'**
  String get optionalObservations;

  /// No description provided for @investmentAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Investment added successfully!'**
  String get investmentAddedSuccessfully;

  /// No description provided for @addAnotherInvestment.
  ///
  /// In en, this message translates to:
  /// **'Add Another Investment'**
  String get addAnotherInvestment;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemTitle;

  /// No description provided for @editItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItemTitle;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemNameLabel;

  /// No description provided for @exampleItemHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Laptop charger'**
  String get exampleItemHint;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// No description provided for @valueExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 120.50'**
  String get valueExampleHint;

  /// No description provided for @pleaseEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get pleaseEnterValue;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @transactionAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully!'**
  String get transactionAddedSuccessfully;

  /// No description provided for @addAnotherTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add another transaction'**
  String get addAnotherTransaction;

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add {type}'**
  String addTransactionTitle(Object type);

  /// No description provided for @addTransactionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'First insert the value of the transaction, then a short commentary if you want to'**
  String get addTransactionSubtitle;

  /// No description provided for @valueHint.
  ///
  /// In en, this message translates to:
  /// **'500,00'**
  String get valueHint;

  /// No description provided for @optionalCommentary.
  ///
  /// In en, this message translates to:
  /// **'Optional commentary'**
  String get optionalCommentary;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsLabel;

  /// No description provided for @cameraNotFound.
  ///
  /// In en, this message translates to:
  /// **'No compatible camera found.'**
  String get cameraNotFound;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required.'**
  String get cameraPermissionRequired;

  /// No description provided for @captureImageError.
  ///
  /// In en, this message translates to:
  /// **'Error capturing image'**
  String get captureImageError;

  /// No description provided for @couldNotExtractSufficientData.
  ///
  /// In en, this message translates to:
  /// **'Could not extract sufficient data.'**
  String get couldNotExtractSufficientData;

  /// No description provided for @newCategoryCreatedPrefix.
  ///
  /// In en, this message translates to:
  /// **'New category created'**
  String get newCategoryCreatedPrefix;

  /// No description provided for @ocrExtractionError.
  ///
  /// In en, this message translates to:
  /// **'Error extracting data'**
  String get ocrExtractionError;

  /// No description provided for @scanInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the Invoice'**
  String get scanInvoiceTitle;

  /// No description provided for @scanInvoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'and register your expense'**
  String get scanInvoiceSubtitle;

  /// No description provided for @invoiceInstructions.
  ///
  /// In en, this message translates to:
  /// **'Position the invoice and press the capture button. Use flash if necessary (top right).'**
  String get invoiceInstructions;

  /// No description provided for @scanYourNF.
  ///
  /// In en, this message translates to:
  /// **'Scan your NF and'**
  String get scanYourNF;

  /// No description provided for @categorizeYourPurchases.
  ///
  /// In en, this message translates to:
  /// **'Categorize your purchases'**
  String get categorizeYourPurchases;

  /// No description provided for @addBill.
  ///
  /// In en, this message translates to:
  /// **'Add Bill'**
  String get addBill;

  /// No description provided for @typeNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Type name cannot be empty'**
  String get typeNameCannotBeEmpty;

  /// No description provided for @addInvestmentTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Investment Type'**
  String get addInvestmentTypeTitle;

  /// No description provided for @addInvestmentTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Give your type a name (e.g. Crypto, Stocks, Real Estate)'**
  String get addInvestmentTypeSubtitle;

  /// No description provided for @exampleInvestmentTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Crypto'**
  String get exampleInvestmentTypeHint;

  /// No description provided for @typeSuccessfullyAdded.
  ///
  /// In en, this message translates to:
  /// **'Type successfully added!'**
  String get typeSuccessfullyAdded;

  /// No description provided for @addAnotherType.
  ///
  /// In en, this message translates to:
  /// **'Add another type'**
  String get addAnotherType;

  /// No description provided for @editInvestmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Investment'**
  String get editInvestmentTitle;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @financials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get financials;

  /// No description provided for @statusAndNotes.
  ///
  /// In en, this message translates to:
  /// **'Status & Notes'**
  String get statusAndNotes;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @investedValueExample.
  ///
  /// In en, this message translates to:
  /// **'1000'**
  String get investedValueExample;

  /// No description provided for @targetValueExample.
  ///
  /// In en, this message translates to:
  /// **'3000'**
  String get targetValueExample;

  /// No description provided for @rateExample.
  ///
  /// In en, this message translates to:
  /// **'0.0021'**
  String get rateExample;

  /// No description provided for @familyManageIntro.
  ///
  /// In en, this message translates to:
  /// **'Here you can manage'**
  String get familyManageIntro;

  /// No description provided for @familyMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyMembersTitle;

  /// No description provided for @aiPhrase1.
  ///
  /// In en, this message translates to:
  /// **'Analyzing family finances...'**
  String get aiPhrase1;

  /// No description provided for @aiPhrase2.
  ///
  /// In en, this message translates to:
  /// **'Generating family report...'**
  String get aiPhrase2;

  /// No description provided for @aiPhrase3.
  ///
  /// In en, this message translates to:
  /// **'Comparing incomes and expenses...'**
  String get aiPhrase3;

  /// No description provided for @aiPhrase4.
  ///
  /// In en, this message translates to:
  /// **'Evaluating everyone\'s investments...'**
  String get aiPhrase4;

  /// No description provided for @aiPhrase5.
  ///
  /// In en, this message translates to:
  /// **'Preparing personalized family insights...'**
  String get aiPhrase5;

  /// No description provided for @aiPhrase6.
  ///
  /// In en, this message translates to:
  /// **'Analyzing finances...'**
  String get aiPhrase6;

  /// No description provided for @aiPhrase7.
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get aiPhrase7;

  /// No description provided for @aiPhrase8.
  ///
  /// In en, this message translates to:
  /// **'Comparing incomes and expenses...'**
  String get aiPhrase8;

  /// No description provided for @aiPhrase9.
  ///
  /// In en, this message translates to:
  /// **'Evaluating investments...'**
  String get aiPhrase9;

  /// No description provided for @aiPhrase10.
  ///
  /// In en, this message translates to:
  /// **'Preparing personalized insights...'**
  String get aiPhrase10;

  /// No description provided for @awaitingAdminInsights.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the admin to generate insights.'**
  String get awaitingAdminInsights;

  /// No description provided for @noInsightsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No insights available'**
  String get noInsightsAvailable;

  /// No description provided for @aiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsightsTitle;

  /// No description provided for @familyAiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Family AI Insights'**
  String get familyAiInsightsTitle;

  /// No description provided for @aiIntro.
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll get,'**
  String get aiIntro;

  /// No description provided for @familySpace.
  ///
  /// In en, this message translates to:
  /// **'Family space'**
  String get familySpace;

  /// No description provided for @manageTransactionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Here, you will manage'**
  String get manageTransactionsIntro;

  /// No description provided for @revenuesExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenues & Expenses'**
  String get revenuesExpensesTitle;

  /// No description provided for @searchCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategoriesHint;

  /// No description provided for @confirmYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get confirmYourEmail;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @iHaveConfirmedLogin.
  ///
  /// In en, this message translates to:
  /// **'I have confirmed'**
  String get iHaveConfirmedLogin;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get vsLastMonth;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @aboutUsFullText.
  ///
  /// In en, this message translates to:
  /// **'# About Econance\n\nEconance, created by a group of young students from the Systems Development technical course, was developed to simplify financial management for individuals and families.\n\nBased on research and the importance of financial education, the app aims to help users control their spending, track their income, and plan their goals in a simple, practical, and accessible way.\n\nWith an intuitive interface and features designed for everyday use, Econance seeks to encourage responsible money habits and contribute to a more balanced and organized financial life.\n\n## Acknowledgements\n\nWe thank everyone who, in some way, contributed to the development of this project.\n\nSpecial thanks to our teacher Débora Paulo, TCC advisor, and to the technical course teachers Mário, Cristiano, Daniel, and Maria Ângela for all their guidance throughout these three years.'**
  String get aboutUsFullText;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please provide your current password.'**
  String get enterCurrentPassword;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'{field} updated successfully!'**
  String updateSuccess(Object field);

  /// No description provided for @noUserLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'No user logged in.'**
  String get noUserLoggedIn;

  /// No description provided for @emailUpdatedAndReauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Email updated and session re-established.'**
  String get emailUpdatedAndReauthenticated;

  /// No description provided for @reloginFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not log in automatically. Please sign in manually.'**
  String get reloginFailed;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutContent;

  /// No description provided for @deactivateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate account'**
  String get deactivateAccountTitle;

  /// No description provided for @deactivateAccountContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to temporarily deactivate your account?'**
  String get deactivateAccountContent;

  /// No description provided for @accountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Account deactivated successfully.'**
  String get accountDeactivated;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. Do you want to continue?'**
  String get deleteAccountContent;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted permanently.'**
  String get accountDeleted;

  /// No description provided for @imageUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image updated successfully!'**
  String get imageUpdatedSuccess;

  /// No description provided for @imageUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating image'**
  String get imageUpdateError;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @changeName.
  ///
  /// In en, this message translates to:
  /// **'Change Name'**
  String get changeName;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @changePhone.
  ///
  /// In en, this message translates to:
  /// **'Change Phone'**
  String get changePhone;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @aboutUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more about Econance'**
  String get aboutUsSubtitle;

  /// No description provided for @updateField.
  ///
  /// In en, this message translates to:
  /// **'Update {field}'**
  String updateField(Object field);

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newField.
  ///
  /// In en, this message translates to:
  /// **'New {field}'**
  String newField(Object field);

  /// No description provided for @selectTypeFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a type first'**
  String get selectTypeFirst;

  /// No description provided for @emailVerificationSentContent.
  ///
  /// In en, this message translates to:
  /// **'An email verification was sent to {email}.\nClick the link to complete the update.'**
  String emailVerificationSentContent(Object email);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
