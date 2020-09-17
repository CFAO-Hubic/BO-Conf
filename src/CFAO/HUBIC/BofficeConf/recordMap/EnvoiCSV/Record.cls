/// RECORDMAP: Generated from RecordMap 'CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV'
/// on 2017-01-09 at 13:03:48.427 [2017-01-09 12:03:48.427 UTC]
/// by user _SYSTEM
Class CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record Extends (%Persistent, %XML.Adaptor, Ens.Request, EnsLib.RecordMap.Base) [ Inheritance = right, ProcedureBlock ]
{

Parameter INCLUDETOPFIELDS = 1;

Property refinterne As %String [ SqlColumnNumber = 2 ];

/// CURRENCY1SHORTNAME
Property Devises As %String [ SqlColumnNumber = 3 ];

/// TRADETYPESHORTNAME
Property TypeOpe As %String [ SqlColumnNumber = 4 ];

/// CPTYSHORTNAME
Property cpty As %String [ SqlColumnNumber = 5 ];

/// AMOUNT1
Property DeviseMontant As %String [ SqlColumnNumber = 6 ];

/// SPOTRATE
Property Spot As %String [ SqlColumnNumber = 7 ];

/// CLIENTRATE
Property CoursTerme As %String [ SqlColumnNumber = 9 ];

/// MATURITYDATE
Property Echeance As %String [ SqlColumnNumber = 10 ];

/// AMOUNT2
Property EURmontant As %String [ SqlColumnNumber = 11 ];

Property TotalDevise As %String [ SqlColumnNumber = 12 ];

/// VALUEDATE
Property DateValeur As %String [ SqlColumnNumber = 13 ];

Property TotalEUR As %String [ SqlColumnNumber = 14 ];

Property TotalDeviseGlobal As %String [ SqlColumnNumber = 15 ];

Property TotalEURGlobal As %String [ SqlColumnNumber = 16 ];

Property TypeTableau As %String [ SqlColumnNumber = 17 ];

Storage Default
{
<Data name="RecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>entitetraitante</Value>
</Value>
<Value name="3">
<Value>%Source</Value>
</Value>
<Value name="4">
<Value>heuretraitementUTC</Value>
</Value>
<Value name="5">
<Value>dateconfirmationUTC</Value>
</Value>
<Value name="6">
<Value>heureconfirmationUTC</Value>
</Value>
<Value name="7">
<Value>compression</Value>
</Value>
<Value name="8">
<Value>contrepartie</Value>
</Value>
<Value name="9">
<Value>UTI</Value>
</Value>
<Value name="10">
<Value>refcontrepartie</Value>
</Value>
<Value name="11">
<Value>refinterne</Value>
</Value>
<Value name="12">
<Value>devtraitee</Value>
</Value>
<Value name="13">
<Value>devcompte</Value>
</Value>
<Value name="14">
<Value>cotation</Value>
</Value>
<Value name="15">
<Value>sensop</Value>
</Value>
<Value name="16">
<Value>typeop</Value>
</Value>
<Value name="17">
<Value>montantdevtraitee</Value>
</Value>
<Value name="18">
<Value>coursspot</Value>
</Value>
<Value name="19">
<Value>coursterme</Value>
</Value>
<Value name="20">
<Value>prixexercice</Value>
</Value>
<Value name="21">
<Value>dateecheance</Value>
</Value>
<Value name="22">
<Value>dateexercice</Value>
</Value>
<Value name="23">
<Value>primeoption</Value>
</Value>
<Value name="24">
<Value>devprime</Value>
</Value>
<Value name="25">
<Value>NDFdevreglement</Value>
</Value>
<Value name="26">
<Value>statutEMIR</Value>
</Value>
<Value name="27">
<Value>dateterminationUTC</Value>
</Value>
<Value name="28">
<Value>DateTraitement</Value>
</Value>
<Value name="29">
<Value>DateTraitementTimeStamp</Value>
</Value>
<Value name="30">
<Value>StatutEnvoiMAilFF</Value>
</Value>
<Value name="31">
<Value>%ParentBatch</Value>
</Value>
<Value name="32">
<Value>datetraitementUTC</Value>
</Value>
<Value name="33">
<Value>TradeDate</Value>
</Value>
<Value name="34">
<Value>TypeOP</Value>
</Value>
<Value name="35">
<Value>Total</Value>
</Value>
<Value name="36">
<Value>ContreValeur</Value>
</Value>
<Value name="37">
<Value>Devises</Value>
</Value>
<Value name="38">
<Value>TypeOpe</Value>
</Value>
<Value name="39">
<Value>cpty</Value>
</Value>
<Value name="40">
<Value>DeviseMontant</Value>
</Value>
<Value name="41">
<Value>Spot</Value>
</Value>
<Value name="42">
<Value>points</Value>
</Value>
<Value name="43">
<Value>CoursTerme</Value>
</Value>
<Value name="44">
<Value>Echeance</Value>
</Value>
<Value name="45">
<Value>EURmontant</Value>
</Value>
<Value name="46">
<Value>TotalDevise</Value>
</Value>
<Value name="47">
<Value>DateValeur</Value>
</Value>
<Value name="48">
<Value>TotalEUR</Value>
</Value>
<Value name="49">
<Value>TotalDeviseGlobal</Value>
</Value>
<Value name="50">
<Value>TotalEURGlobal</Value>
</Value>
<Value name="51">
<Value>TypeTableau</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBIC.BofficeCC76D.RecordD</DataLocation>
<DefaultData>RecordDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^CFAO.HUBIC.BofficeCC76D.RecordD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofficeCC76D.RecordI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofficeCC76D.RecordS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

Relationship %ParentBatch As CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV [ Cardinality = one, Inverse = Records ];

Index %ParentBatchIdx On %ParentBatch;

Parameter RECORDMAPGENERATED = 1;

}
