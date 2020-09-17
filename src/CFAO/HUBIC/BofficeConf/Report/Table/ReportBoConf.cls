Class CFAO.HUBIC.BofficeConf.Report.Table.ReportBoConf Extends (CFAO.HUBIC.Report.AbstractRecord, %XML.Adaptor) [ Inheritance = right ]
{

/// Table de reporting pour les fichiers 
Property NomFichier As %String(MAXLEN = 2000);

Property TypeFichier As %String(MAXLEN = 20);

Storage Default
{
<Data name="ReportBoConfDefaultData">
<Subscript>"ReportBoConf"</Subscript>
<Value name="1">
<Value>NomFichier</Value>
</Value>
<Value name="2">
<Value>TypeFichier</Value>
</Value>
</Data>
<DefaultData>ReportBoConfDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
