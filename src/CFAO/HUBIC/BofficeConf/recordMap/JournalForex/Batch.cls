/// RECORDMAP: Modified during compilation of RecordMap 'CFAO.HUBIC.BofficeConf.recordMap.JournalForex'
/// on 2019-11-06 at 09:30:32.921 [2019-11-06 08:30:32.921 UTC]
/// by user _SYSTEM
Class CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch Extends (%Library.Persistent, EnsLib.RecordMap.SimpleBatch)
{

Parameter XMLNAME = "BF";

Parameter RECORDMAPGENERATED = 1;

Parameter BatchHeader = "ID;TRADE_DATE;CPTY_SHORTNAME;CURRENCY1_SHORTNAME;TRADE_TYPE;AMOUNT1;CLIENT_RATE;AMOUNT2;REMAINING_AMOUNT1;APPLICATIVE_STATUS_NAME;REFERENCE;VALUE_DATE;MATURITY_DATE;SPOT_RATE;UTI;PARENT TRADE;CURRENCY2_SHORTNAME";

Parameter HeaderTerm = "\x0d\x0a";

Parameter BatchTrailer;

Parameter TrailerTerm;

Parameter IgnoreLeadingData = 0;

Relationship Records As CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Record [ Cardinality = many, Inverse = %ParentBatch ];

Trigger OnDelete [ Event = DELETE ]
{
	Set %ok = ..deleteRecords({ID})
}

Parameter XMLTYPE = "CFAO_HUBIC_BofficeConf_recordMap_JournalForex_Batch";

Storage Default
{
<Data name="BatchDefaultData">
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
<DataLocation>^CFAO.HUBIC.BofficeCoB3C9.BatchD</DataLocation>
<DefaultData>BatchDefaultData</DefaultData>
<IdLocation>^CFAO.HUBIC.BofficeCoB3C9.BatchD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofficeCoB3C9.BatchI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofficeCoB3C9.BatchS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
