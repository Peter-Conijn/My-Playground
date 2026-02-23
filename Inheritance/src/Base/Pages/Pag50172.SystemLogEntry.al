page 50172 "System Log Entry"
{
    ApplicationArea = All;
    Caption = 'System Log Entry';
    PageType = Document;
    SourceTable = "System Log Entry";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Application ID"; Rec."Application ID")
                {
                    ToolTip = 'Specifies the application ID of the system log entry.';
                }
                field("Application Name"; Rec."Application Name")
                {
                    ToolTip = 'Specifies the application name of the system log entry.';
                }
            }
            part(LoggedSystemEntries; "Logged System Entries")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InitializeLogEntry)
            {
                Caption = 'Initialize Log Entry';
                ToolTip = 'Initializes the system log entry with default values.';
                Image = New;

                trigger OnAction()
                begin
                    GlobalSystemLog.Clear();

                    Rec.Init();
                    Rec."Application ID" := CreateGuid();
                    Rec."Application Name" := 'My Application';
                end;
            }
            action(InsertLogEntry)
            {
                Caption = 'Insert Log Entry';
                ToolTip = 'Inserts the system log entry into the system log.';
                Image = Save;

                trigger OnAction()
                begin
                    InsertEntry();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(InitializeLogEntry_Promoted; InitializeLogEntry)
                {
                }
                actionref(InsertLogEntry_Promoted; InsertLogEntry)
                {
                }
            }
        }
    }
    var
        GlobalSystemLog: Codeunit "System Log";

    local procedure InsertEntry()
    begin
        GlobalSystemLog.InitEntry(Rec."Application ID", Rec."Application Name");

        OnBeforeInsertLogEntry(Rec, GlobalSystemLog);
        GlobalSystemLog.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertLogEntry(var TempSystemLogEntry: Record "System Log Entry" temporary; var GlobalSystemLog: Codeunit "System Log")
    begin
    end;

}
