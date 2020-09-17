Class CFAO.HUBIC.BofficeConf.Report.EmailPJ.DataTransform.ReportOK Extends Ens.DataTransformDTL [ DependsOn = (Ens.StringRequest, CFAO.HUBIC.BofficeConf.Report.Table.ReportBoConf) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='Ens.StringRequest' targetClass='CFAO.HUBIC.BofficeConf.Report.Table.ReportBoConf' create='new' language='objectscript' >
<assign value='source.StringValue' property='target.SourceFileName' action='set' />
<assign value='source.StringValue' property='target.NomFichier' action='set' />
<assign value='##class(Ens.DataType.UTC).timeUTCtoLocal(context.%Process.%TimeCreated)' property='target.FileInTime' action='set' />
<assign value='..CurrentDateTime()' property='target.FileOutTime' action='set' />
<assign value='"BoConfmail"' property='target.Emetteur' action='set' />
<assign value='"CFAO"' property='target.Recepteur' action='set' />
<assign value='"Récupération Mail"' property='target.NomFlux' action='set' />
<assign value='"0"' property='target.Status' action='set' />
<assign value='context.%Process.%SessionId' property='target.IDsession' action='set' />
<assign value='"EMail"' property='target.TypeFichier' action='set' />
<code>
<![CDATA[ Do target.%Save()]]></code>
</transform>
}

}
