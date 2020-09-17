/// RECORDMAP: Modified during compilation of RecordMap 'CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV'
/// on 2017-01-09 at 13:03:48.486 [2017-01-09 12:03:48.486 UTC]
/// by user _SYSTEM
Class CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV Extends (%Library.Persistent, EnsLib.RecordMap.SimpleBatch)
{

Parameter XMLNAME = "BenvCSV";

Parameter RECORDMAPGENERATED = 1;

Parameter BatchHeader;

Parameter HeaderTerm = "\x0d\x0a";

Parameter BatchTrailer;

Parameter TrailerTerm;

Parameter IgnoreLeadingData = 0;

Relationship Records As CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record [ Cardinality = many, Inverse = %ParentBatch ];

Trigger OnDelete [ Event = DELETE ]
{
	Set %ok = ..deleteRecords({ID})
}

Parameter XMLTYPE = "CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV_BenvCSV";

Storage Default
{
<Data name="BenvCSVDefaultData">
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
<DataLocation>^CFAO.HUBIC.BofficeC76D.BenvCSVD</DataLocation>
<DefaultData>BenvCSVDefaultData</DefaultData>
<IdLocation>^CFAO.HUBIC.BofficeC76D.BenvCSVD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofficeC76D.BenvCSVI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofficeC76D.BenvCSVS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
