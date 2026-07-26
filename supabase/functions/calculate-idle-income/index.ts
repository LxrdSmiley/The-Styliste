import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { handleKingstonRequest } from "../_shared/kingston_contract.ts";
import { KINGSTON_ROUTES } from "../_shared/kingston_routes.ts";

serve((request) =>
  handleKingstonRequest(request, KINGSTON_ROUTES["calculate-idle-income"])
);
