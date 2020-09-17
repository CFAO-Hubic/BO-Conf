/// RECORDMAP: Generated from RecordMap 'CFAO.HUBIC.BofficeConf.recordMap.JournalForex'
/// on 2019-11-06 at 09:30:32.875 [2019-11-06 08:30:32.875 UTC]
/// by user _SYSTEM
Class CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Record Extends (%Persistent, %XML.Adaptor, Ens.Request, EnsLib.RecordMap.Base) [ Inheritance = right, ProcedureBlock ]
{

Parameter INCLUDETOPFIELDS = 1;

Property IDforex As %String [ Required, SqlColumnNumber = 2 ];

Property TRADEDATE As %String [ Required, SqlColumnNumber = 3 ];

Property CPTYSHORTNAME As %String [ Required, SqlColumnNumber = 4 ];

Property CURRENCY1SHORTNAME As %String [ Required, SqlColumnNumber = 5 ];

Property TRADETYPESHORTNAME As %String [ Required, SqlColumnNumber = 6 ];

Property AMOUNT1 As %String [ Required, SqlColumnNumber = 7 ];

Property CLIENTRATE As %String [ Required, SqlColumnNumber = 8 ];

Property AMOUNT2 As %String [ Required, SqlColumnNumber = 9 ];

Property REMAININGAMOUNT1 As %String [ SqlColumnNumber = 10 ];

Property APPLICATIVESTATUSNAME As %String [ Required, SqlColumnNumber = 11 ];

Property REFERENCE As %String [ Required, SqlColumnNumber = 12 ];

Property VALUEDATE As %String [ Required, SqlColumnNumber = 13 ];

Property MATURITYDATE As %String [ SqlColumnNumber = 14 ];

Property SPOTRATE As %String [ Required, SqlColumnNumber = 15 ];

Property UTICCI As %String(MAXLEN = 500) [ SqlColumnNumber = 16 ];

Property PARENTTRADECCE As %String [ SqlColumnNumber = 17 ];

Property CURRENCY2SHORTNAME As %String [ SqlColumnNumber = 18 ];

Storage Default
{
<Data name="RecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>IDforex</Value>
</Value>
<Value name="3">
<Value>%Source</Value>
</Value>
<Value name="4">
<Value>CPTYSHORTNAME</Value>
</Value>
<Value name="5">
<Value>CURRENCY1SHORTNAME</Value>
</Value>
<Value name="6">
<Value>TRADETYPESHORTNAME</Value>
</Value>
<Value name="7">
<Value>AMOUNT1</Value>
</Value>
<Value name="8">
<Value>CLIENTRATE</Value>
</Value>
<Value name="9">
<Value>AMOUNT2</Value>
</Value>
<Value name="10">
<Value>REMAININGAMOUNT1</Value>
</Value>
<Value name="11">
<Value>APPLICATIVESTATUSNAME</Value>
</Value>
<Value name="12">
<Value>REFERENCE</Value>
</Value>
<Value name="13">
<Value>VALUEDATE</Value>
</Value>
<Value name="14">
<Value>MATURITYDATE</Value>
</Value>
<Value name="15">
<Value>SPOTRATE</Value>
</Value>
<Value name="16">
<Value>UTICCI</Value>
</Value>
<Value name="17">
<Value>PARENTTRADECCE</Value>
</Value>
<Value name="18">
<Value>%ParentBatch</Value>
</Value>
<Value name="19">
<Value>TRADEDATE</Value>
</Value>
<Value name="20">
<Value>CURRENCY2SHORTNAME</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBIC.BofficeCB3C9.RecordD</DataLocation>
<DefaultData>RecordDefaultData</DefaultData>
<ExtentSize>2000000</ExtentSize>
<IdLocation>^CFAO.HUBIC.BofficeCB3C9.RecordD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BofficeCB3C9.RecordI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BofficeCB3C9.RecordS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

Relationship %ParentBatch As CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch [ Cardinality = one, Inverse = Records ];

Index %ParentBatchIdx On %ParentBatch;

Parameter RECORDMAPGENERATED = 1;

}
