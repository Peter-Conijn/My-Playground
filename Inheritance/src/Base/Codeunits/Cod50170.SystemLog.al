codeunit 50170 "System Log"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        GlobalSystemLogEntry: Record "System Log Entry";
        Initialized: Boolean;

    /// <summary>
    /// Initializes a new system log entry with the specified application details.
    /// </summary>
    /// <param name="ApplicationID">The unique identifier for the application.</param>
    /// <param name="ApplicationName">The name of the application.</param>
    procedure InitEntry(ApplicationID: Guid; ApplicationName: Text[100])
    begin
        if this.IsInitialized() then
            this.Clear();
        GlobalSystemLogEntry.Init();
        GlobalSystemLogEntry."Entry No." := GetNextEntryNo();

        this.SetInitialized();

        this.SetApplicationID(ApplicationID);
        this.SetApplicationName(ApplicationName);
    end;

    /// <summary>
    /// Clears all internal state and resets the codeunit.
    /// </summary>
    procedure Clear()
    begin
        ClearAll();
    end;

    /// <summary>
    /// Checks whether the codeunit has been initialized.
    /// </summary>
    /// <returns>True if initialized, false otherwise.</returns>
    procedure IsInitialized(): Boolean
    begin
        exit(Initialized);
    end;

    /// <summary>
    /// Validates that the codeunit has been initialized and throws an error if not.
    /// </summary>
    procedure CheckInitialized()
    var
        NotInitializedErr: Label 'System Log Codeunit is not initialized.';
    begin
        if not this.IsInitialized() then
            Error(NotInitializedErr);
    end;

    /// <summary>
    /// Inserts the initialized system log entry into the database.
    /// </summary>
    [InherentPermissions(PermissionObjectType::TableData, Database::"System Log Entry", 'I')]
    procedure Insert()
    begin
        this.CheckInitialized();
        GlobalSystemLogEntry.Insert();
        this.Clear();
    end;

    /// <summary>
    /// Retrieves the initialized system log entry record.
    /// </summary>
    /// <returns>The system log entry record.</returns>
    procedure GetEntryRecord(): Record "System Log Entry"
    begin
        this.CheckInitialized();
        exit(GlobalSystemLogEntry);
    end;

    /// <summary>
    /// Sets the application ID for the system log entry.
    /// </summary>
    /// <param name="ApplicationID">The unique identifier for the application. Cannot be an empty GUID.</param>
    procedure SetApplicationID(ApplicationID: Guid)
    var
        NullGuidErr: Label 'Application ID cannot be empty GUID.';
    begin
        this.CheckInitialized();
        if IsNullGuid(ApplicationID) then
            Error(NullGuidErr);

        this.SetField(GlobalSystemLogEntry.FieldNo("Application ID"), ApplicationID);
    end;

    /// <summary>
    /// Sets the application name for the system log entry.
    /// </summary>
    /// <param name="ApplicationName">The name of the application.</param>
    procedure SetApplicationName(ApplicationName: Text[100])
    begin
        this.CheckInitialized();
        this.SetField(GlobalSystemLogEntry.FieldNo("Application Name"), ApplicationName);
    end;

    /// <summary>
    /// Sets a field value for the system log entry.
    /// </summary>
    /// <param name="FieldNo">The field number to set.</param>
    /// <param name="FieldValue"> The value to set for the field.</param>
    procedure SetField(FieldNo: Integer; FieldValue: Variant)
    var
        ModifyBlockedErr: Label 'Cannot modify Entry No. field.';
        RecordRef: RecordRef;
    begin
        CheckInitialized();
        if FieldNo = GlobalSystemLogEntry.FieldNo("Entry No.") then
            Error(ModifyBlockedErr);

        RecordRef.GetTable(GlobalSystemLogEntry);
        RecordRef.Field(FieldNo).Value := FieldValue;
        RecordRef.SetTable(GlobalSystemLogEntry);
    end;

    local procedure GetNextEntryNo(): Integer
    var
        SystemLogEntry: Record "System Log Entry";
        LastEntryNo: Integer;
    begin
        SystemLogEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        SystemLogEntry.SetLoadFields("Entry No.");
        if SystemLogEntry.FindLast() then
            LastEntryNo := SystemLogEntry."Entry No.";

        exit(LastEntryNo + 1);
    end;

    local procedure SetInitialized()
    begin
        Initialized := true;
    end;
}
