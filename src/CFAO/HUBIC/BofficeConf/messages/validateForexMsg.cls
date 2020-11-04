Class CFAO.HUBIC.BofficeConf.messages.validateForexMsg Extends Ens.Response
{

Property invalid As %String(MAXLEN = 99999);

Property duplicate As %String(MAXLEN = 99999);

Property inTab As %String(MAXLEN = 99999);

Property processed As %String(MAXLEN = 99999);

Property fileName As %String(MAXLEN = 999);

Property status As %Integer;

Property test As array Of %String;

Property test2 As list Of %String;

Storage Default
{
<Data name="test">
<Attribute>test</Attribute>
<Structure>subnode</Structure>
<Subscript>"CFAO.HUBIC.BofficeConf.messages.validateForexMsg.test"</Subscript>
</Data>
<Data name="validateForexMsgDefaultData">
<Subscript>"validateForexMsg"</Subscript>
<Value name="1">
<Value>invalid</Value>
</Value>
<Value name="2">
<Value>duplicate</Value>
</Value>
<Value name="3">
<Value>inTab</Value>
</Value>
<Value name="4">
<Value>processed</Value>
</Value>
<Value name="5">
<Value>fileName</Value>
</Value>
<Value name="6">
<Value>status</Value>
</Value>
<Value name="7">
<Value>test2</Value>
</Value>
</Data>
<DefaultData>validateForexMsgDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
