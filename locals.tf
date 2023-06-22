locals {
  private_route_table_ids = [module.subnets["app"].route_table_ids, module.subnets["web"].route_table_ids, module.subnets["db"].route_table_ids]
  all_route_table_ids     = [module.subnets["app"].route_table_ids, module.subnets["web"].route_table_ids, module.subnets["db"].route_table_ids, module.subnets["public"].route_table_ids]
}

