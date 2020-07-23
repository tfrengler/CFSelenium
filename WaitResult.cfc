<cfcomponent modifier="final" output="false" hint="" >

    <cfset variables.StartTime = now() />
    <cfset variables.EndTime = null />
    <cfset variables.TimedOut = false />
    <cfset variables.LastException = null />
    <cfset variables.Value = null />
    <cfset variables.Iterations = 0 />
    <cfset variables.Duration = 0 />

    <cfset this.HadException = ()=> {return !isNull(variables.LastException)} />
    <cfset this.Success = ()=> {return !variables.TimedOut} />
    <cfset this.GetIterations = ()=> {return variables.Iterations} /> 
    <cfset this.GetStartTime = ()=> {return variables.StartTime} />
    <cfset this.GetEndTime = ()=> {return variables.EndTime} />
    <cfset this.GetTimedOut = ()=> {return variables.TimedOut} />
    <cfset this.GetLastException = ()=> {return variables.LastException} />
    <cfset this.TimeTaken = ()=> {return variables.Duration} />
    <cfset this.GetValue = ()=> {return variables.Value} />

    <cfset this.Iterate = ()=> {if(variables.EndTime == null) variables.Iterations++} />
    <cfset this.SetException = (required object exception)=> {variables.LastException = arguments.exception} />

	<cffunction name="Finish" returntype="WaitResult" access="public" hint="XXX" output="true" >
        <cfargument name="value" type="any" required="false" hint="" />
        <cfargument name="timedOut" type="boolean" required="true" hint="" />
        <cftimer label="Finish">
        <cfset variables.TimedOut = arguments.timedOut />
        <cfset variables.EndTime = now() />
        <cfset variables.Duration = dateDiff("s", variables.StartTime, variables.EndTime) />

        <cfif structKeyExists(arguments, "Value") >
            <cfset variables.Value = arguments.value />
        </cfif>

        </cftimer>
        <cfreturn this />
    </cffunction>
    
</cfcomponent>