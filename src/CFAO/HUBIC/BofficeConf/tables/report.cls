Class CFAO.HUBIC.BofficeConf.tables.report Extends (CFAO.HUBIC.Report.AbstractRecord, %XML.Adaptor) [ Inheritance = right ]
{

Property TypeFichier As %String(MAXLEN = 20);

Storage Default
{
<Data name="reportDefaultData">
<Subscript>"report"</Subscript>
<Value name="1">
<Value>TypeFichier</Value>
</Value>
</Data>
<DefaultData>reportDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
