{: GLTexture<p>

   Handles all the color and texture stuff.<p>

	<b>Historique : </b><font size=-1><ul>
      <li>24/03/00 - Egg - Fixed SetScene not updating enablings
		<li>13/03/00 - Egg - Object names (ie. node text) is now properly adjusted
									when a GLScene object is renamed,
									Added Load/Save whole scene
      <li>07/02/00 - Egg - Fixed notification logic
      <li>06/02/00 - Egg - DragDrop now starts after moving the mouse a little,
                           Form is now auto-creating, fixed Notification,
                           Added actionlist and moveUp/moveDown
      <li>05/02/00 - Egg - Fixed DragDrop, added root nodes auto-expansion
   </ul></font>
}
unit GLSceneEdit;

interface

uses
  Windows, Forms, ComCtrls, GLScene, Menus, ActnList, ToolWin, DsgnIntf,
  Controls, Classes, ImgList, Dialogs;

type

  TGLSceneEditorForm = class(TForm)
    Tree: TTreeView;
    PopupMenu: TPopupMenu;
    MIAddCamera: TMenuItem;
    MIAddObject: TMenuItem;
    N1: TMenuItem;
    MIDelObject: TMenuItem;
    ToolBar: TToolBar;
    ActionList: TActionList;
    ToolButton1: TToolButton;
    TBAddObjects: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    PMToolBar: TPopupMenu;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ACAddCamera: TAction;
    ACAddObject: TAction;
    ImageList: TImageList;
    ACDeleteObject: TAction;
    ACMoveUp: TAction;
    ACMoveDown: TAction;
    N2: TMenuItem;
    Moveobjectup1: TMenuItem;
    Moveobjectdown1: TMenuItem;
    ACSaveScene: TAction;
    ACLoadScene: TAction;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ToolButton2: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
	 procedure FormCreate(Sender: TObject);
    procedure TreeEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
    procedure TreeEdited(Sender: TObject; Node: TTreeNode; var S: String);
    procedure TreeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure TreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TreeEnter(Sender: TObject);
    procedure TreeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ACAddCameraExecute(Sender: TObject);
    procedure ACDeleteObjectExecute(Sender: TObject);
    procedure ACMoveUpExecute(Sender: TObject);
    procedure ACMoveDownExecute(Sender: TObject);
    procedure ACAddObjectExecute(Sender: TObject);
    procedure ACSaveSceneExecute(Sender: TObject);
    procedure ACLoadSceneExecute(Sender: TObject);

  private
    FScene: TGLScene;
    FObjectNode, FCameraNode: TTreeNode;
    FCurrentDesigner: IFormDesigner;
    FLastMouseDownPos : TPoint;
	 procedure ReadScene;
    procedure ResetTree;
    function AddNodes(ANode: TTreeNode; AObject: TGLBaseSceneObject): TTreeNode;
    procedure AddObjectClick(Sender: TObject);
	 procedure SetObjectsSubItems(parent : TMenuItem);
	 procedure OnBaseSceneObjectNameChanged(Sender : TObject);

  protected
	 procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    procedure SetScene(Scene: TGLScene; Designer: IFormDesigner);

  end;

function GLSceneEditorForm : TGLSceneEditorForm;
procedure ReleaseGLSceneEditorForm;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

{$R *.DFM}

uses GLSceneRegister, GLStrings;

var
	vGLSceneEditorForm : TGLSceneEditorForm;

function GLSceneEditorForm : TGLSceneEditorForm;
begin
	if not Assigned(vGLSceneEditorForm) then begin
		vGLSceneEditorForm:=TGLSceneEditorForm.Create(Application);
		RegisterGLBaseSceneObjectNameChangeEvent(vGLSceneEditorForm.OnBaseSceneObjectNameChanged);
	end;
	Result:=vGLSceneEditorForm;
end;

procedure ReleaseGLSceneEditorForm;
begin
	if Assigned(vGLSceneEditorForm) then begin
		DeRegisterGLBaseSceneObjectNameChangeEvent(vGLSceneEditorForm.OnBaseSceneObjectNameChanged);
		vGLSceneEditorForm.Free; vGLSceneEditorForm:=nil;
	end;
end;

// FindNodeByData
//
function FindNodeByData(treeNodes : TTreeNodes; data : Pointer;
								baseNode : TTreeNode = nil) : TTreeNode;
var
	n : TTreeNode;
begin
	Result:=nil;
	if Assigned(baseNode) then begin
		n:=baseNode.getFirstChild;
		while Assigned(n) do begin
			if n.Data=data then begin
				Result:=n; Break;
			end else	if n.HasChildren then begin
				Result:=FindNodeByData(treeNodes, data, n);
				if Assigned(Result) then Break;
			end;
			n:=baseNode.GetNextChild(n);
		end;
	end else begin
		n:=treeNodes.GetFirstNode;
		while Assigned(n) do begin
			if n.Data=data then begin
				Result:=n; Break;
			end else	if n.HasChildren then begin
				Result:=FindNodeByData(treeNodes, data, n);
				if Assigned(Result) then Break;
			end;
			n:=n.getNextSibling;
		end;
	end;
end;

//----------------- TGLSceneEditorForm ---------------------------------------------------------------------------------

// SetScene
//
procedure TGLSceneEditorForm.SetScene(Scene: TGLScene; Designer: IFormDesigner);
begin
	if Assigned(FScene) then
		FScene.RemoveFreeNotification(Self);
   FScene:=Scene;
   FCurrentDesigner:=Designer;
   ResetTree;
   if Assigned(FScene) then begin
      FScene.FreeNotification(Self);
      ReadScene;
      Caption:='GLScene editor: ' + FScene.Name;
   end else Caption:='GLScene editor';
   TreeChange(Self, nil);
end;

// FormCreate
//
procedure TGLSceneEditorForm.FormCreate(Sender: TObject);
var
   CurrentNode: TTreeNode;
begin
   Tree.Images:=ObjectManager.ObjectIcons;
   Tree.Indent:=ObjectManager.ObjectIcons.Width;
   with Tree.Items do begin
      // first add the scene root
      CurrentNode:=Add(nil, glsSceneRoot);
      with CurrentNode do begin
         ImageIndex:=ObjectManager.SceneRootIndex;
         SelectedIndex:=ImageIndex;
      end;
      // next the root for all cameras
      FCameraNode:=AddChild(CurrentNode, glsCameraRoot);
      with FCameraNode do begin
         ImageIndex:=ObjectManager.CameraRootIndex;
         SelectedIndex:=ObjectManager.CameraRootIndex;
      end;
      // and the root for all objects
      FObjectNode:=AddChild(CurrentNode, glsObjectRoot);
      with FObjectNode do begin
         ImageIndex:=ObjectManager.ObjectRootIndex;
         SelectedIndex:=ObjectManager.ObjectRootIndex;
      end;
   end;
   // Build SubMenus
   SetObjectsSubItems(MIAddObject);
   MIAddObject.SubMenuImages:=ObjectManager.ObjectIcons;
   SetObjectsSubItems(PMToolBar.Items);
   PMToolBar.Images:=ObjectManager.ObjectIcons;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TGLSceneEditorForm.ReadScene;

var
  I: Integer;

begin
  Tree.Items.BeginUpdate;
  with FScene do
  begin
    if Assigned(Cameras) then
    begin
      FCameraNode.Data:=Cameras;
      for I:=0 to Cameras.Count - 1 do AddNodes(FCameraNode, Cameras[I]);
      FCameraNode.Expand(False);
    end;

    if Assigned(Objects) then
	 begin
      FObjectNode.Data:=Objects;
      with Objects do
        for I:=0 to Count - 1 do AddNodes(FObjectNode, Children[I]);
      FObjectNode.Expand(False);
    end;
  end;
  Tree.Items.EndUpdate;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TGLSceneEditorForm.ResetTree;
begin
   // delete all subtrees (empty tree)
   Tree.Items.BeginUpdate;
   try
      FCameraNode.DeleteChildren;
      FCameraNode.Data:=nil;
      with FObjectNode do begin
         DeleteChildren;
			Data:=nil;
         Parent.Expand(True);
      end;
   finally
      Tree.Items.EndUpdate;
   end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TGLSceneEditorForm.AddNodes(ANode: TTreeNode; AObject: TGLBaseSceneObject): TTreeNode;

// adds the given scene object as well as its children to the tree structure and returns
// the last add node (e.g. for selection)

var
  I: Integer;
  CurrentNode: TTreeNode;

begin
  Result:=Tree.Items.AddChildObject(ANode, AObject.Name, AObject);
  Result.ImageIndex:=ObjectManager.GetImageIndex(TGLSceneObjectClass(AObject.ClassType));
  Result.SelectedIndex:=Result.ImageIndex;
  CurrentNode:=Result;
  for I:=0 to AObject.Count - 1 do Result:=AddNodes(CurrentNode, AObject[I]);
end;

procedure TGLSceneEditorForm.SetObjectsSubItems(parent : TMenuItem);
var
   objectList: TStringList;
   i: Integer;
   item: TMenuItem;
begin
   objectList:=TStringList.Create;
   try
      ObjectManager.GetRegisteredSceneObjects(objectList);
      for i:=0 to objectList.Count-1 do begin
         item:=NewItem(ObjectList[I], 0, False, True, AddObjectClick, 0, '');
         with ObjectManager do
            item.ImageIndex:=GetImageIndex(GetClassFromIndex(i));
         parent.Add(item);
      end;
	finally
      objectList.Free;
   end;
end;

procedure TGLSceneEditorForm.AddObjectClick(Sender: TObject);
var
   AParent, AObject: TGLBaseSceneObject;
   Node: TTreeNode;
begin
   if Assigned(FCurrentDesigner) then with Tree do
      if Assigned(Selected) and (Selected.Level > 0) then begin
         AParent:=TGLBaseSceneObject(Selected.Data);
         AObject:=AParent.AddNewChild(ObjectManager.GetClassFromIndex(TMenuItem(Sender).MenuIndex));
         AObject.Name:=FCurrentDesigner.UniqueName(AObject.Classname);
         Node:=AddNodes(Selected, AObject);
         Node.Selected:=True;
         FCurrentDesigner.Modified;
      end;
end;

procedure TGLSceneEditorForm.TreeDragOver(Sender, Source: TObject; X, Y: Integer;
                                          State: TDragState; var Accept: Boolean);
var
   Target : TTreeNode;
begin
   Accept:=False;
   if Source=Tree then with Tree do begin
      Target:=DropTarget;
      Accept:=Assigned(Target) and (Selected <> Target)
                and Assigned(Target.Data) and (not Target.HasAsParent(Selected));
   end;
end;

procedure TGLSceneEditorForm.TreeDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   SourceNode, DestinationNode: TTreeNode;
   SourceObject, DestinationObject: TGLBaseSceneObject;
begin
   if Assigned(FCurrentDesigner) then begin
      DestinationNode:=Tree.DropTarget;
      if Assigned(DestinationNode) and (Source = Tree) then begin
			SourceNode:=TTreeView(Source).Selected;
         SourceObject:=SourceNode.Data;
         DestinationObject:=DestinationNode.Data;
         DestinationObject.Insert(0, SourceObject);
         SourceNode.MoveTo(DestinationNode, naAddChildFirst);
         FCurrentDesigner.Modified;
      end;
   end;
end;

procedure TGLSceneEditorForm.Notification(AComponent: TComponent; Operation: TOperation);
begin
   if (FScene=AComponent) and (Operation=opRemove) then
      SetScene(nil, nil)
   else inherited;
end;

// OnBaseSceneObjectNameChanged
//
procedure TGLSceneEditorForm.OnBaseSceneObjectNameChanged(Sender : TObject);
var
	n : TTreeNode;
begin
	n:=FindNodeByData(Tree.Items, Sender);
	if Assigned(n) then
		n.Text:=(Sender as TGLBaseSceneObject).Name;
end;

// TreeChange
//
procedure TGLSceneEditorForm.TreeChange(Sender: TObject; Node: TTreeNode);
var
   selNode : TTreeNode;
begin
   if Assigned(FCurrentDesigner) then begin
      selNode:=Tree.Selected;
      // select in Delphi IDE
      if Assigned(selNode) then begin
         if Assigned(selNode.Data) then
            FCurrentDesigner.SelectComponent(selNode.Data)
         else FCurrentDesigner.SelectComponent(FScene);
         // enablings
         ACAddCamera.Enabled:=(selNode=FCameraNode);
         ACAddObject.Enabled:=((selNode=FObjectNode) or selNode.HasAsParent(FObjectNode));
         ACDeleteObject.Enabled:=(selNode.Level>1);
         ACMoveUp.Enabled:=(ACAddObject.Enabled and (selNode.Index>0));
         ACMoveDown.Enabled:=(ACAddObject.Enabled and (selNode.GetNextSibling<>nil));
      end else begin
         ACAddCamera.Enabled:=False;
         ACAddObject.Enabled:=False;
         ACDeleteObject.Enabled:=False;
         ACMoveUp.Enabled:=False;
         ACMoveDown.Enabled:=False;
      end;
   end;
end;

procedure TGLSceneEditorForm.TreeEditing(Sender: TObject; Node: TTreeNode;
                                         var AllowEdit: Boolean);
begin
   AllowEdit:=(Node.Level>1);
end;

procedure TGLSceneEditorForm.TreeEdited(Sender: TObject; Node: TTreeNode; var S: String);
begin
   if Assigned(FCurrentDesigner) then begin
      // renaming a node means renaming a scene object
      TGLBaseSceneObject(Node.Data).Name:=S;
      FCurrentDesigner.Modified;
   end;
end;

procedure TGLSceneEditorForm.TreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   FLastMouseDownPos:=Point(X, Y);
end;

procedure TGLSceneEditorForm.TreeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
   node: TTreeNode;
begin
   if Shift=[ssLeft] then begin
      node:=Tree.Selected;
      if Assigned(node) and (node.Level>1) then
         if (Abs(FLastMouseDownPos.x-x)>4) or (Abs(FLastMouseDownPos.y-y)>4) then
            Tree.BeginDrag(False);
   end;
end;

procedure TGLSceneEditorForm.TreeEnter(Sender: TObject);
begin
   if Assigned(FCurrentDesigner) and Assigned(Tree.Selected) then
      FCurrentDesigner.SelectComponent(Tree.Selected.Data);
end;

procedure TGLSceneEditorForm.ACAddCameraExecute(Sender: TObject);
var
   AObject: TGLBaseSceneObject;
   Node: TTreeNode;
begin
   if Assigned(FCurrentDesigner) then begin
      AObject:=FScene.Cameras.AddNewChild(TGLCamera);
      AObject.Name:=FCurrentDesigner.UniqueName(AObject.Classname);
      Node:=AddNodes(FCameraNode, AObject);
      Node.Selected:=True;
      FCurrentDesigner.Modified;
   end;
end;

procedure TGLSceneEditorForm.ACDeleteObjectExecute(Sender: TObject);
var
	AObject: TGLBaseSceneObject;
   Allowed, KeepChildren: Boolean;
   ConfirmMsg: String;
   Buttons: TMsgDlgButtons;
begin
   if Assigned(Tree.Selected) and (Tree.Selected.Level > 1) then begin
      AObject:=TGLBaseSceneObject(Tree.Selected.Data);
      // ask for confirmation
      if AObject.Name <> '' then
         ConfirmMsg:='Delete ' + AObject.Name
      else ConfirmMsg:='Delete the marked object';
      Buttons:=[mbOK, mbCancel];
      // are there children to care for?
      if AObject.Count > 0 then begin
         ConfirmMsg:=ConfirmMsg + ' and all its children?';
         Buttons:=[mbAll] + Buttons;
      end else ConfirmMsg:=ConfirmMsg + '?';
      case MessageDlg(ConfirmMsg, mtConfirmation, Buttons, 0) of
         mrAll : begin
            KeepChildren:=False;
            Allowed:=True;
			end;
         mrOK : begin
            KeepChildren:=True;
            Allowed:=True;
         end;
         mrCancel : begin
            Allowed:=False;
            KeepChildren:=True;
         end;
      else
         Allowed:=False;
         KeepChildren:=True;
      end;
      // deletion allowed?
      if allowed then begin
         AObject.Parent.Remove(AObject, KeepChildren);
         AObject.Free;
         Tree.Selected.Free;
      end
   end;
end;

procedure TGLSceneEditorForm.ACMoveUpExecute(Sender: TObject);
var
   node : TTreeNode;
begin
   if ACMoveUp.Enabled then begin
      node:=Tree.Selected;
      if Assigned(node) then begin
         node.MoveTo(node.GetPrevSibling, naInsert);
         with TGLBaseSceneObject(node.Data) do begin
            MoveUp;
            Update;
         end;
         TreeChange(Self, node);
      end;
   end;
end;

procedure TGLSceneEditorForm.ACMoveDownExecute(Sender: TObject);
var
   node : TTreeNode;
begin
   if ACMoveDown.Enabled then begin
      node:=Tree.Selected;
      if Assigned(node) then begin
         node.GetNextSibling.MoveTo(node, naInsert);
         with TGLBaseSceneObject(node.Data) do begin
            MoveDown;
            Update;
         end;
			TreeChange(Self, node);
		end;
	end;
end;

procedure TGLSceneEditorForm.ACAddObjectExecute(Sender: TObject);
begin
	TBAddObjects.CheckMenuDropdown;
end;

procedure TGLSceneEditorForm.ACSaveSceneExecute(Sender: TObject);
begin
	if SaveDialog.Execute then
		FScene.SaveToFile(SaveDialog.FileName);
end;

procedure TGLSceneEditorForm.ACLoadSceneExecute(Sender: TObject);
begin
	if OpenDialog.Execute then begin
		FScene.LoadFromFile(OpenDialog.FileName);
		ResetTree;
		ReadScene;
	end;
end;

initialization

finalization

   ReleaseGLSceneEditorForm;

end.
