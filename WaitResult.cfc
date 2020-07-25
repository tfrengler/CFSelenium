<cfcomponent modifier="final" output="false" persistent="true" hint="" >

	<cfset variables.StartTime = now() />
	<cfset variables.EndTime = null />
	<cfset variables.TimedOut = false />
	<cfset variables.LastException = null />
	<cfset variables.Value = null />
	<cfset variables.Iterations = 0 />
	<cfset variables.Duration = 0 />

	<cfproperty name="StartTime"		type="date"		getter="true"	setter="false" 	hint="" />
	<cfproperty name="EndTime"			type="date"		getter="true"	setter="false" 	hint="" />
	<cfproperty name="TimedOut"			type="boolean"	getter="true"	setter="false" 	hint="" />
	<cfproperty name="Value"			type="any"		getter="true"	setter="false" 	hint="" />
	<cfproperty name="Iterations"		type="numeric"	getter="true"	setter="false" 	hint="" />
	<cfproperty name="Duration"			type="numeric"	getter="true"	setter="false" 	hint="" />
	<cfproperty name="LastException"	type="any"		getter="true"	setter="true" 	hint="" />

	<cfset this.HadException = ()=> {return !isNull(variables.LastException)} />
	<cfset this.Success = ()=> {return !variables.TimedOut} />
	<cfset this.Iterate = ()=> {if(variables.EndTime == null) variables.Iterations++} />

	<cffunction name="Finish" returntype="WaitResult" access="public" hint="XXX" output="true" >
		<cfargument name="value" type="any" required="false" hint="" />
		<cfargument name="timedOut" type="boolean" required="false" default="false" hint="" />

		<cfset variables.TimedOut = arguments.timedOut />
		<cfset variables.EndTime = now() />
		<cfset variables.Duration = dateDiff("s", variables.StartTime, variables.EndTime) />

		<cfif structKeyExists(arguments, "Value") >
			<cfset variables.Value = arguments.value />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="init" returntype="WaitResult" access="public" hint="Constructor" >

		<cfset variables.StartTime = now() />
		<cfset variables.EndTime = null />
		<cfset variables.TimedOut = false />
		<cfset variables.LastException = null />
		<cfset variables.Value = null />
		<cfset variables.Iterations = 0 />
		<cfset variables.Duration = 0 />

		<cfreturn this />
	</cffunction>
</cfcomponent>