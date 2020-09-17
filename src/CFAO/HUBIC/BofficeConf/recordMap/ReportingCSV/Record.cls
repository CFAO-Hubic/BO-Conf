/// RECORDMAP: Generated from RecordMap 'CFAO.HUBIC.BofficeConf.recordMap.ReportingCSV'
/// on 2016-10-17 at 14:36:14.288 [2016-10-17 13:36:14.288 UTC]
/// by user _SYSTEM
Class CFAO.HUBIC.BofficeConf.recordMap.ReportingCSV.Record Extends (%Persistent, %XML.Adaptor, Ens.Request, EnsLib.RecordMap.Base) [ Inheritance = right, ProcedureBlock ]
{

Parameter INCLUDETOPFIELDS = 1;

Property TypeOperation As %String;

Property Devise As %String;

Property ContrePartieBancaire As %String;

Property MontantDevise As %String;

Property CoursTerme As %String;

Property DateEcheance As %String;

Property ContreValeur As %String;

Relationship %ParentBatch As CFAO.HUBIC.BofficeConf.recordMap.ReportingCSV.BRepCSV [ Cardinality = one, Inverse = Records ];

Index %ParentBatchIdx On %ParentBatch;

Parameter RECORDMAPGENERATED = 1;

Storage Default
{
<Data name="RecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>TypeOperatino</Value>
</Value>
<Value name="3">
<Value>%Source</Value>
</Value>
<Value name="4">
<Value>ContrepartieBancaire</Value>
</Value>
<Value name="5">
<Value>MontantDevise</Value>
</Value>
<Value name="6">
<Value>Coursterme</Value>
</Value>
<Value name="7">
<Value>DateEcheance</Value>
</Value>
<Value name="8">
<Value>ContreValeur</Value>
</Value>
<Value name="9">
<Value>%ParentBatch</Value>
</Value>
<Value name="10">
<Value>Devise</Value>
</Value>
<Value name="11">
<Value>TypeOperation</Value>
</Value>
<Value name="12">
<Value>ContrePartieBancaire</Value>
</Value>
<Value name="13">
<Value>CoursTerme</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBIC.BofficeCD3AC.RecordD</DataLocation>
<DefaultData>RecordDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^CFAO.HUBIC.BofficeCD3AC.RecordD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofficeCD3AC.RecordI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofficeCD3AC.RecordS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
