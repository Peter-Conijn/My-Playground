codeunit 50171 "System Log Extension"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        GlobalSystemLog: Codeunit "System Log";

    /// <summary>
    /// Initializes the extension with a reference to the base System Log codeunit.
    /// </summary>
    /// <param name="NewSystemLog">The base System Log codeunit instance to associate with this extension.</param>
    procedure Init(var NewSystemLog: Codeunit "System Log")
    begin
        this.GlobalSystemLog := NewSystemLog;
    end;

    /// <summary>
    /// Retrieves the base System Log codeunit instance.
    /// </summary>
    /// <returns>The base System Log codeunit.</returns>
    procedure GetBase(): Codeunit "System Log"
    begin
        exit(this.GlobalSystemLog);
    end;

    /// <summary>
    /// Sets the application version for the system log entry.
    /// </summary>
    /// <param name="VersionNo">The version number of the application.</param>
    procedure SetVersion(VersionNo: Text[10])
    var
        SystemLogEntry: Record "System Log Entry";
    begin
        this.GlobalSystemLog.CheckInitialized();
        this.GlobalSystemLog.SetField(SystemLogEntry.FieldNo("Application Version"), VersionNo);
    end;
}
