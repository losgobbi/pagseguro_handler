module PagSeguroHelper
  class PagSeguroState
    # state machine according to https://pagseguro.uol.com.br/v2/guia-de-integracao/api-de-notificacoes.html
    STATE_INICIO = 0
    STATE_AGUARDANDO_PAGAMENTO = 1
    STATE_EM_ANALISE = 2
    STATE_PAGA = 3
    STATE_DISPONIVEL = 4
    STATE_EM_DISPUTA = 5
    STATE_DEVOLVIDA = 6
    STATE_CANCELADA = 7
    STATE_FIM = 8

    attr_accessor :previous_state, :current_state

    def initialize(previous, current)
      @previous_state = previous
      @current_state = current
    end

    def pending?
      if ((@previous_state == STATE_AGUARDANDO_PAGAMENTO && @current_state == STATE_EM_ANALISE) ||
          (@previous_state == STATE_INICIO && @current_state == STATE_EM_ANALISE))
        return true
      else
        return false
      end
    end

    def checkout_pending?
      if (@previous_state == STATE_EM_ANALISE && @current_state == STATE_PAGA)
        return true
      else
        return false
      end
    end

    def credit?
      if ((@previous_state == STATE_INICIO && @current_state == STATE_PAGA) ||
          (@previous_state == STATE_AGUARDANDO_PAGAMENTO && @current_state == STATE_PAGA))
        return true
      else
        return false
      end
    end

    def canceled?
      if (@previous_state == STATE_EM_ANALISE && @current_state == STATE_CANCELADA)
        return true
      else
        return false
      end
    end

    def to_s
      desc = [ "Início", "Aguardando pagamento", "Em análise", "Paga",
               "Disponível", "Em disputa", "Devolvida", "Cancelada", "Fim"]
      return "previous state " + desc.fetch(@previous_state) + " current state " + desc.fetch(@current_state)
    end
  end
end
