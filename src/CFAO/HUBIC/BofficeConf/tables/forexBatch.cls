Class CFAO.HUBIC.BofficeConf.tables.forexBatch Extends (%Persistent, %XML.Adaptor) [ Inheritance = right ]
{

Property forexRecords As array Of CFAO.HUBIC.BofficeConf.tables.forex;

Storage Default
{
<Data name="forexBatchDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<Data name="forexRecords">
<Attribute>forexRecords</Attribute>
<Structure>subnode</Structure>
<Subscript>"forexRecords"</Subscript>
</Data>
<DataLocation>^CFAO.HUBIC.BoffAB75.forexBatchD</DataLocation>
<DefaultData>forexBatchDefaultData</DefaultData>
<IdLocation>^CFAO.HUBIC.BoffAB75.forexBatchD</IdLocation>
<IndexLocation>^CFAO.HUBIC.BoffAB75.forexBatchI</IndexLocation>
<StreamLocation>^CFAO.HUBIC.BoffAB75.forexBatchS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
