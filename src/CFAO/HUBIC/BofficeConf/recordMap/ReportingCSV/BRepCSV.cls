/// RECORDMAP: Modified during compilation of RecordMap 'CFAO.HUBIC.BofficeConf.recordMap.ReportingCSV'
/// on 2016-10-17 at 14:36:14.307 [2016-10-17 13:36:14.307 UTC]
/// by user _SYSTEM
Class CFAO.HUBIC.BofficeConf.recordMap.ReportingCSV.BRepCSV Extends (%Library.Persistent, EnsLib.RecordMap.SimpleBatch)
{

Parameter XMLNAME = "BRepCSV";

Parameter RECORDMAPGENERATED = 1;

Parameter BatchHeader;

Parameter HeaderTerm;

Parameter BatchTrailer;

Parameter TrailerTerm;

Parameter IgnoreLeadingData = 0;

Relationship Records As CFAO.HUBIC.BofficeConf.recordMap.ReportingCSV.Record [ Cardinality = many, Inverse = %ParentBatch ];

Trigger OnDelete [ Event = DELETE ]
{
	Set %ok = ..deleteRecords({ID})
}

Parameter XMLTYPE = "CFAO_HUBIC_BofficeConf_recordMap_ReportingCSV_BRepCSV";

Storage Default
{
<Data name="BRepCSVDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>%Source</Value>
</Value>
<Value name="3">
<Value>BatchHeader</Value>
</Value>
<Value name="4">
<Value>BatchTrailer</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBIC.BofficeD3AC.BRepCSVD</DataLocation>
<DefaultData>BRepCSVDefaultData</DefaultData>
<IdLocation>^CFAO.HUBIC.BofficeD3AC.BRepCSVD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofficeD3AC.BRepCSVI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofficeD3AC.BRepCSVS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
