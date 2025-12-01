import 'dart:convert';
import 'package:artrit/data/data_spr_diagnoses.dart';
import 'package:artrit/data/data_spr_region.dart';
import 'package:artrit/data/data_spr_relationship.dart';
import 'package:artrit/data/data_spr_research_tuberculin_result.dart';
import 'package:artrit/data/data_spr_sections.dart';
import 'package:artrit/data/data_spr_temperature.dart';
import 'package:flutter/cupertino.dart';
import '../data/data_spr_doctors.dart';
import '../data/data_spr_drugs.dart';
import '../data/data_spr_frequency.dart';
import '../data/data_spr_hospitals.dart';
import '../data/data_spr_other_tests_names.dart';
import '../data/data_spr_other_tests_units.dart';
import '../data/data_spr_relatives.dart';
import '../data/data_spr_research_tuberculin_type.dart';
import '../data/data_spr_side_effects.dart';
import '../data/data_spr_treatment_drug_forms.dart';
import '../data/data_spr_treatment_drug_provision.dart';
import '../data/data_spr_treatment_drug_using_rate.dart';
import '../data/data_spr_treatment_drug_using_way.dart';
import '../data/data_spr_treatment_rehabilitations_types.dart';
import '../data/data_spr_treatment_results.dart';
import '../data/data_spr_treatment_skipping_reasons.dart';
import '../data/data_spr_treatment_units.dart';
import '../data/data_spr_vaccination.dart';
import 'base_client.dart';
import '../data/data_spr_tests_group.dart';
import '../data/data_tests_options.dart';


var baseClient = BaseClient();

class ApiSpr {


  Future<List<DataSprRegion>> getRegions() async {
    var response =
    await baseClient.get('/api/lookups/regions?lookupName=regions');
    List<DataSprRegion> thisData = dataSprRegionFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden).toList();
    debugPrint(jsonEncode(thisData));
    return thisData;
  }



  Future<List<DataSprHospitals>> getHospitals() async {
    var response =
    await baseClient.get('/api/lookups/hospitals?lookupName=hospitals');
    List<DataSprHospitals> thisData = dataSprHospitalsFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<List<DataSprDoctors>> getDoctors() async {
    var response =
    await baseClient.get('/api/lookups/doctors?lookupName=doctors');
    List<DataSprDoctors> thisData = dataSprDoctorsFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  // Future<List<DataSprRelationship>> getRelationship() async {
  //   var response =
  //   await baseClient.get('/api/lookups/relationship-degrees?lookupName=relationship-degrees');
  //   List<DataSprRelationship> thisData = dataSprRelationshipFromJson(response.body);
  //   thisData = thisData.where((e) => !e.isHidden).toList();
  //   debugPrint(jsonEncode(thisData));
  //   return thisData;
  // }


  Future<List<DataSprRelationship>> getRelationship() async {
    var response =
    await baseClient.get('/api/lookups/relationship-degrees');
    List<DataSprRelationship> thisData = dataSprRelationshipFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<List<DataSprDiagnoses>> getDiagnoses() async {
    var response =
    await baseClient.get('/api/diagnoses');
    List<DataSprDiagnoses> thisData = dataSprDiagnosesFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<List<double>> getTemperature() async {
    var response =
    await baseClient.get('/api/lookups/temperature?lookupName=temperature');
    List<DataSprTemperature> thisData = dataSprTemperatureFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden).toList();
    List<double> listSprTemperature = thisData
        .map((e) => e.name ?? 0)
        .toList()
      ..sort();
    return listSprTemperature;
  }

  Future<List<String>> getTestsGroup() async {
    var response =
    await baseClient.get('/api/lookups/analysisgroup?lookupName=analysisgroup');
    List<DataSprTestsGroup> thisData = dataSprTestsGroupFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden).toList();
    List<String> list = thisData
        .map((e) => e.name)
        .toList()
      ..sort();
    return list;
  }


  Future<List<DataTestsOptions>> getTestsOptions(int fullAge) async {
    var response =
    await baseClient.get('/api/analysispatient/GetMinMax/$fullAge');
    List<DataTestsOptions> thisData = dataTestsOptionsFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<List<DataSprOtherTestsNames>> getNamesForOtherTest() async {
    var response = await baseClient.get(
        '/api/analysispatient/getotherbloodtestsanalysis');
    List<DataSprOtherTestsNames> thisData = dataSprOtherTestsNamesFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<List<DataSprOtherTestsUnits>> getUnitForOtherTest({
    required String recordId,
  }) async {
    var response = await baseClient.get(
        '/api/analysispatient/getotherbloodtestsunits/$recordId');
    List<DataSprOtherTestsUnits> thisData = dataSprOtherTestsUnitsFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<List<DataSprDrugs>> getDrugs() async {
    var response =
    await baseClient.get('/api/drugs');
    List<DataSprDrugs> thisData = dataSprDrugsFromJson(response.body);
    return thisData;
  }

  Future<List<DataSprSideEffects>> getSideEffects() async {
    var response =
    await baseClient.get('/api/lookups/side-effect-types?lookupName=side-effect-types');
    List<DataSprSideEffects> thisData = dataSprSideEffectsFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden).toList();
    return thisData;
  }


  Future<List<DataSprResearchTuberculinType>> getResearchTuberculosisType() async {
    var response =
    await baseClient.get('/api/lookups/research-items?lookupName=research-items');
    List<DataSprResearchTuberculinType> thisData = dataSprResearchTuberculinTypeFromJson(response.body);
    return thisData;
  }

  Future<List<DataSprResearchTuberculinResult>> getResearchTuberculosisResult() async {
    var response =
    await baseClient.get('/api/lookups/results?lookupName=results');
    List<DataSprResearchTuberculinResult> thisData = dataSprResearchTuberculinResultFromJson(response.body);
    return thisData;
  }



  Future<List<String>> getTreatmentUnits({
    required String recordId,
  }) async {
    var response =
    await baseClient.get('/api/lookups/units/$recordId');
    List<DataSprTreatmentUnits> thisData = dataSprTreatmentUnitsFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    List<String> list = thisData
        .map((e) => e.name ?? '')
        .toList();
    return list;
  }



  Future<List<String>> getTreatmentDrugForms() async {
    var response =
    await baseClient.get('/api/lookups/drug-release-forms?lookupName=drug-release-forms');
    List<DataSprTreatmentDrugForms> thisData = dataSprTreatmentDrugFormsFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    List<String> list = thisData
        .map((e) => e.name ?? '')
        .toList();
    return list;
  }



  Future<List<String>> getTreatmentDrugProvision() async {
    var response =
    await baseClient.get('/api/lookups/drug-provision-types?lookupName=drug-provision-types');
    List<DataSprTreatmentDrugProvision> thisData = dataSprTreatmentDrugProvisionFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    List<String> list = thisData
        .map((e) => e.name ?? '')
        .toList();
    return list;
  }



  Future<List<String>> getTreatmentDrugUsingRate() async {
    var response =
    await baseClient.get('/api/lookups/drug-use-rates?lookupName=drug-use-rates');
    List<DataSprTreatmentDrugUsingRate> thisData = dataSprTreatmentDrugUsingRateFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    List<String> list = thisData
        .map((e) => e.name ?? '')
        .toList();
    return list;
  }



  Future<List<DataSprTreatmentDrugUsingWay>> getTreatmentDrugUsingWay() async {
    var response =
    await baseClient.get('/api/lookups/drug-using-methods?lookupName=drug-using-methods');
    List<DataSprTreatmentDrugUsingWay> thisData = dataSprTreatmentDrugUsingWayFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    return thisData;
  }



  Future<List<DataSprTreatmentSkippingReasons>> getTreatmentSkippingReasons() async {
    var response =
    await baseClient.get('/api/lookups/medicine-skipping-reasons?lookupName=medicine-skipping-reasons');
    List<DataSprTreatmentSkippingReasons> thisData = dataSprTreatmentSkippingReasonsFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    return thisData;
  }


  Future<List<DataSprTreatmentResults>> getTreatmentResults() async {
    var response =
    await baseClient.get('/api/lookups/treatment-results?lookupName=treatment-results');
    List<DataSprTreatmentResults> thisData = dataSprTreatmentResultsFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    return thisData;
  }


  Future<List<DataSprTreatmentRehabilitationsTypes>> getTreatmentRehabilitationsTypes() async {
    var response =
    await baseClient.get('/api/lookups/rehabilitation-types?lookupName=rehabilitation-types');
    List<DataSprTreatmentRehabilitationsTypes> thisData = dataSprTreatmentRehabilitationsTypesFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    return thisData;
  }



  Future<List<DataSprVaccination>> getVaccination() async {
    var response =
    await baseClient.get('/api/lookups/spr-vaccination?lookupName=spr-vaccination');
    List<DataSprVaccination> thisData = dataSprVaccinationFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    return thisData;
  }




  Future<List<DataSprRelatives>> getRelatives() async {
    var response =
    await baseClient.get('/api/lookups/relatives?lookupName=relatives');
    List<DataSprRelatives> thisData = dataSprRelativesFromJson(response.body);
    thisData = thisData.where((e) => !e.isHidden!).toList();
    return thisData;
  }




  Future<List<DataSprFrequency>> getFrequency() async {
    var response =
    await baseClient.get('/api/notificationSettings/frequences');
    List<DataSprFrequency> thisData = dataSprFrequencyFromJson(response.body);
    return thisData;
  }




  Future<List<DataSprSections>> getSections() async {
    var response =
    await baseClient.get('/api/notificationSettings/sections');
    List<DataSprSections> thisData = dataSprSectionsFromJson(response.body);
    return thisData;
  }








}
