#!/usr/bin/env python
import i3
from gi.repository import Gtk, Gdk
from gio import app_info_get_all

VETO_NAMES=("topdock","bottomdock","__i3_scratch")

def filter_func(model, treeiter, user_data):
    query = entry.get_text().lower()
    value = model.get_value(treeiter, 0).lower()
    if value not in VETO_NAMES:
        for q in query.split(" "):
            if q not in value: return False
            # elif all q's in value:
        return True
    else:
        return False

def sort_func(model, a, b, user_data):
    a_id, b_id = model.get_value(a,1), model.get_value(b,1)
    a_name, b_name = model.get_value(a,0), model.get_value(b,0)
    if a_id == -1 and b_id != -1:
        return -1
    elif a_id == -1 and b_id == -1 or (a_id > -1 and b_id > -1):
        if a_name.lower() == b_name.lower(): return 0
        elif a_name.lower() > b_name.lower(): return -1
        else: return 1
    elif a_id > -1 and b_id == -1:
        return 1

def refilter(*_):
    filterStore.refilter()
    if filterStore.get_iter_first():
        tree.get_selection().select_iter(filterStore.get_iter_first())
        tree.set_cursor( filterStore.get_path( filterStore.get_iter_first() ) )

def activate(*_):
    model, treeiter = tree.get_selection().get_selected()
    conid = model.get_value(treeiter, 1)
    if conid > -1:
        i3.command("[con_id={conid}] focus".format(conid=conid))
    else:
        app_id = model.get_value(treeiter, 2)
        apps[app_id].launch()
    Gtk.main_quit()

def win_key_press(widget,event):
    if Gdk.keyval_name( event.keyval ) == "Escape":
        Gtk.main_quit()
    elif not entry.is_focus(): 
        if event.string:
            entry.grab_focus()

def tree_move_up(widget,event):
    if Gdk.keyval_name( event.keyval ) == "Up":
        (model, it1) = widget.get_selection().get_selected()
        if model.get_string_from_iter(it1) == "0":
            entry.grab_focus()

win = Gtk.Window(title="fooswitcher")
box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
win.add(box)

entry = Gtk.Entry()
box.pack_start(entry, False, False, 0)

store = Gtk.ListStore(str,int,str,str)
for con in i3.filter(type=4):
    if con['name'] in VETO_NAMES: continue
    store.append(["Workspace: " + con['name'], con['id'], "","gtk-home"])
for con in i3.filter(type=2,nodes=[]):
    if con['name'] in VETO_NAMES: continue
    store.append([con['name'], con['id'], "","gtk-fullscreen"])

apps = dict(map(lambda o: (o.get_id(), o), app_info_get_all()))
for app_id, app in apps.items():
    store.append([app.get_name(), -1, app_id, "gtk-execute"])

filterStore = Gtk.TreeModelFilter(child_model=store)

tree = Gtk.TreeView(filterStore)
tree.set_enable_search(False)
tree.set_headers_visible(False)

tree.append_column(Gtk.TreeViewColumn("", Gtk.CellRendererPixbuf(), stock_id=3))
tree.append_column(Gtk.TreeViewColumn("", Gtk.CellRendererText(), text=0))

box.pack_start(Gtk.ScrolledWindow(child=tree), True, True, 0)

store.set_sort_func(0, sort_func, None)
store.set_sort_column_id(0, Gtk.SortType.DESCENDING)
filterStore.set_visible_func(filter_func)

entry.connect("changed", refilter)
entry.connect("activate", activate)
tree.connect("row-activated", activate)
tree.connect("key-press-event", tree_move_up)
win.connect("key-press-event", win_key_press)
win.connect("delete-event", Gtk.main_quit)

win.set_type_hint(Gdk.WindowTypeHint.DIALOG)
win.set_default_size(400,300)
win.show_all()

refilter()
Gtk.main()