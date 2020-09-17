/// règles métiers des fichiers AZAP PR Produits
Class CFAO.HUBIC.BofficeConf.Rules.BRulesBoConf Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "Ens.Rule.GeneralBusinessRuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="" production="">
<ruleSet name="RuleLogBoConf" effectiveBegin="" effectiveEnd="">
<rule name="BoConfVerifStatutName" disabled="false">
<when condition="BoConfVerifStatutName(contextJrnForex)=1">
<assign property="resultUserDesc" value="&quot;Ligne au statut non validated trouvées&quot;"></assign>
<return>1</return>
</when>
</rule>
<rule name="BoConfVerifDoublonsInFile" disabled="false">
<when condition="BoConfVerifDoublonsInFile(contextJrnForex)=1">
<assign property="resultUserDesc" value="&quot;Au moins un Id Forex en double dans le fichier&quot;"></assign>
<return>1</return>
</when>
</rule>
<rule name="BoConfVerifDejalisteRappro" disabled="false">
<when condition="BoConfVerifDejalisteRappro(contextJrnForex)=1">
<assign property="resultUserDesc" value="&quot;Un Id Forex existe deja dans la liste de rapprochement&quot;"></assign>
<return>1</return>
</when>
</rule>
<rule name="BoConfVerifDejaTraiter" disabled="false">
<when condition="BoConfVerifDejaTraiter(contextJrnForex)=1">
<assign property="resultUserDesc" value="&quot;Au moins une ligne déja été envoyer à Forex Finance&quot;"></assign>
<return>1</return>
</when>
</rule>
<return>0</return>
</ruleSet>
</ruleDefinition>
}

}
