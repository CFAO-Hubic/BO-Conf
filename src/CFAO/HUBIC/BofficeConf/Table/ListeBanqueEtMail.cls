Class CFAO.HUBIC.BofficeConf.Table.ListeBanqueEtMail Extends %Persistent
{

Property NomBanque As %String(MAXLEN = 2000) [ SqlColumnNumber = 2 ];

Property CodeBanque As %String [ SqlColumnNumber = 3 ];

Property DestinataireMail As %String(MAXLEN = 200) [ SqlColumnNumber = 4 ];

Property DestinataireNom As %String(MAXLEN = 200) [ SqlColumnNumber = 5 ];

Property DateCreation As %String [ SqlColumnNumber = 6 ];

Property DateModif As %String [ SqlColumnNumber = 7 ];

Property DestinataireMailCopy As %String(MAXLEN = 200) [ SqlColumnNumber = 8 ];

Storage Default
{
<Data name="ListeBanqueEtMailDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>NomBanque</Value>
</Value>
<Value name="3">
<Value>CodeBanque</Value>
</Value>
<Value name="4">
<Value>DestinataireMail</Value>
</Value>
<Value name="5">
<Value>DestinataireNom</Value>
</Value>
<Value name="6">
<Value>DateCreation</Value>
</Value>
<Value name="7">
<Value>DateModif</Value>
</Value>
<Value name="8">
<Value>DestinataireCopyMail</Value>
</Value>
<Value name="9">
<Value>VARDestinataireMailCopy</Value>
</Value>
<Value name="10">
<Value>DestinataireMailCopy</Value>
</Value>
</Data>
<DataLocation>^CFAO.HUBICF369.ListeBanqueEDFCD</DataLocation>
<DefaultData>ListeBanqueEtMailDefaultData</DefaultData>
<IdLocation>^CFAO.HUBICF369.ListeBanqueEDFCD</IdLocation>
<IndexLocation>^CFAO.HUBICF369.ListeBanqueEDFCI</IndexLocation>
<StreamLocation>^CFAO.HUBICF369.ListeBanqueEDFCS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
