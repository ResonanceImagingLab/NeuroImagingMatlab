function struct_var2 = sub_set_att(struct_var,att_name,val_att)

struct_var2 = struct_var;

list_att = struct_var.varatts;

mask_att = niak_find_str_cell(list_att,att_name);

pos = find(mask_att);

if ~isempty(pos)

    struct_var2.attvalue{pos} = val_att;
else
    struct_var2.varatts{end+1} = att_name;
    struct_var2.attvalue{end+1} = val_att;
end