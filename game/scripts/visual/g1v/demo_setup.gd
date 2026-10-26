extends RefCounted
## One-time authored demonstration, earned entirely through existing service commands.
var value: float = 0
var serial: int = 0
func now() -> float: return value
func command(service: RefCounted, type: String, args: Dictionary) -> Dictionary:
	serial += 1
	args.merge({"type":type,"request_id":"g1v.demo."+str(serial)})
	var result: Dictionary = service.execute(args)
	if not result.ok: push_error("G1V demo setup: "+str(result))
	return result
func seed(service: RefCounted) -> void:
	if int(service.state.revision)>0: return
	var original: Callable = service.clock.source
	var current: float = service.clock.now_seconds()
	value = (current-10000)/service.clock.rate
	service.clock.source = now
	while int(service.state.economy.xp)<32:
		if int(service.state.inventory.seeds.get("crop.carrot",0))<1:
			if not command(service,"buy_seeds",{"crop_id":"crop.carrot","quantity":1}).ok: break
		var plant := command(service,"plant",{"plot_id":"plot.home.a","crop_id":"crop.carrot"})
		value += 140/service.clock.rate
		if not command(service,"harvest",{"plot_id":"plot.home.a","cycle_id":plant.get("cycle_id","")}).ok: break
		command(service,"sell_products",{"items":{"crop.carrot":2}})
	var crops := ["crop.bean","crop.rose","crop.carrot","crop.strawberry"]
	var plots := ["plot.home.a","plot.home.b","plot.home.c","plot.home.d"]
	var ages := [1800,400,25,3000]
	for i in range(4):
		value = (current-float(ages[i]))/service.clock.rate
		command(service,"buy_seeds",{"crop_id":crops[i],"quantity":2})
		command(service,"plant",{"plot_id":plots[i],"crop_id":crops[i]})
	service.clock.source = original
