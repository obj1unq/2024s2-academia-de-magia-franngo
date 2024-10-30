class Academia {
	const property muebles

	method estaEnLaAcamedia(cosa) {
		return muebles.any({mueble => mueble.contieneCosa(cosa)})
	}

	//no recuerdo exactamente que devolvía el find si no encontraba ninguna coincidencia (¿null?). NO. tira error! (Y esta bien eso)
	//sino, puedo usar filter que devuelve la lista de los que cumplen (y si ninguno cumple, devuelve lista vacía)
	//Según profe: NO TIENE MUCHO SENTIDO HACER VALIDACIONES EN MÉTODOS DE CONSULTA. Son más propios de métodos de orden.
	method enQueMuebleEstaGuardado(cosa) {
		return muebles.find({mueble => mueble.contieneCosa(cosa)})
	}

	method sePuedeGuardarEnLaAcademia(cosa) {
		return (!self.estaEnLaAcamedia(cosa)) && muebles.any({mueble => mueble.puedeGuardarCosa(cosa)})
	}

	method mueblesQuePuedenAlojar(cosa) {
		return muebles.filter({mueble => mueble.puedeGuardarCosa(cosa)})
	}

	method guardarEnLaAcademia(cosa) {
		self.validarGuardarEnLaAcademia(cosa)
		self.mueblesQuePuedenAlojar(cosa).anyOne().guardarCosa(cosa) //acá puedo meter subtarea!
	}

	method validarGuardarEnLaAcademia(cosa) {
		if(!self.sePuedeGuardarEnLaAcademia(cosa)) {
			self.error("No se puede guardar la cosa")
		}
	}

	method cosasMenosUtiles() {
		return muebles.map({mueble => mueble.cosaMenosUtil()})
	}

	method cosaMenosUtil() {
		const menosUtiles = self.cosasMenosUtiles()
		return menosUtiles.min({cosa => cosa.utilidadQueAporta()})
	}

	method marcaMenosUtil() {
		return self.cosaMenosUtil().marca() //agarramos la MENOS ÚTIL y devolvemos la marca
	}

	method removerNiUtilesNiMagicas() {
		self.validarCantMuebles()
		const cosasARemover = self.cosasNiUtilesNiMagicas()
		cosasARemover.forEach({cosa => self.enQueMuebleEstaGuardado(cosa).remover(cosa)}) //lo de adentro del foreach podría haberlo
																						  //realizado en una subtarea de la academia!
	}

	method validarCantMuebles() {
		if(muebles.size() < 3) {
			self.error("La academia no tiene la cantidad de muebles suficiente para hacer eso")
		}
	}

	method cosasNiUtilesNiMagicas() {
		const menosUtiles = self.cosasMenosUtiles()
		return menosUtiles.filter({cosa => !cosa.esElementoMagico()})
	}

}

class Mueble {

	const cosasGuardadas = #{}

	method guardarCosa(cosa) {
		self.validarGuardarCosa(cosa) //esta validación es innecesaria (ya se valida en el método de la academia. Posterior a eso, se elige una para guardar cosa y directamente se le ordena que la guarde)
		cosasGuardadas.add(cosa)
	}

	method validarGuardarCosa(cosa) { //INNECESARIA
		if(!self.puedeGuardarCosa(cosa)) {
			self.error("No se puede guardar esta cosa en este mueble")
		}
	}

	//podía ser con contains!!
	method contieneCosa(cosaBuscada) {
		return cosasGuardadas.any({cosa => cosa == cosaBuscada})
	}

	method puedeGuardarCosa(cosa)

	method utilidad() {
		return self.utilidadCosas() / self.precio()
	}

	method utilidadCosas() {
		return cosasGuardadas.sum({cosa => cosa.utilidadQueAporta()})
	}

	method precio()

	method cosaMenosUtil() {
		return cosasGuardadas.min({cosa => cosa.utilidadQueAporta()})
	}

	method remover(cosa) {
		cosasGuardadas.remove(cosa)
	}

}

class Baul inherits Mueble {
	const volumenMax

	method volumenUsado() {
		return cosasGuardadas.sum({cosa => cosa.volumen()})
	}

	override method puedeGuardarCosa(cosa) {
		return cosa.volumen()+self.volumenUsado() <= volumenMax
	}

	override method precio() {
		return volumenMax + 2
	}

	override method utilidad() {
		return super() + self.dosSiSonTodasReliquias() 
	}

	method tieneTodasReliquias() {
		return cosasGuardadas.all({cosa => cosa.esReliquia()})
	}

	method dosSiSonTodasReliquias() { //podría llamarse simplemente extra. Es muy de implementación ese nombre
		return if (self.tieneTodasReliquias()) 2 else 0
	}

}

class BaulMagico inherits Baul {

	//PARA LA EJECUCIÓN DE LOS MÉTODOS DE SUBCLASES SE COMIENZA VIENDO SI EXISTE UNA IMPLEMENTACIÓN EN LA MISMA CLASE (la clase que
	//se instanció con new). Esto es el método lookup para encontrar la implementación correspondiente de cada método
	//si NO existe en la subclase, se sube a la superclase. Si no existe en esta, se sube a su superclase.
	override method utilidad() {
		return super() + self.extraElemMag()
	}

	method extraElemMag() {
		return cosasGuardadas.count({cosa => cosa.esElementoMagico()})
	}

	override method precio() {
		return super() * 2
	}

}

class GabineteMagico inherits Mueble {
	const property precio 

	override method puedeGuardarCosa(cosa) {
		return cosa.esElementoMagico()
	}

}

class Armario inherits Mueble {
	var property maxDeObjetos

	override method validarGuardarCosa(cosa) {
		if(cosasGuardadas.size() == maxDeObjetos) {
			self.error("No se puede guardar este elemento porque el mueble ya está lleno")
		}
	}

	override method puedeGuardarCosa(cosa) {
		return cosasGuardadas.size() < maxDeObjetos
	}

	override method precio() {
		return 5 * maxDeObjetos
	}

}

class Cosa {
	const property marca
	const property volumen
	const property esElementoMagico
	const property esReliquia

	method utilidadQueAporta() {
		return volumen + self.tresSiEsMagica() + self.cincoSiEsReliquia() + marca.utilidadQueAportaA(self)
	}

	method cincoSiEsReliquia() { //podría usar ternary operator
		if(self.esReliquia()) {
			return 5
		} else {
			return 0
		}
	}

	method tresSiEsMagica() {
		if(self.esElementoMagico()) { //podría usar ternary operator
			return 3
		} else {
			return 0
		}
	}

}

//Debería modelar las marcas en vez de que sean strings
object acme {

	method utilidadQueAportaA(cosa) {
		return cosa.volumen() / 2
	}

}
object fenix {

	method utilidadQueAportaA(cosa) { //podría usar ternary operator
		if(cosa.esReliquia()) {
			return 3
		} else {
			return 0
		}
	}

}
object cuchuflito {

	method utilidadQueAportaA(cosa) {
		return 0
	}

}
